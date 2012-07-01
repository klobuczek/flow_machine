module FlowMachine
  def self.included(base)
    base.extend ClassMethods
    base.helper_method :next_url, :flow_group, :flow_reachable?, :direct_url
  end

  module ClassMethods
    def flow options
      @@flow_condition ||= {}
      [:if, :unless].each { |attr| options[attr] = ([@@flow_condition[attr]] + [options[attr]]).flatten.compact }
      @@flows ||= []
      @@flows << options
    end

    def flows
      @@flows
    end

    def flow_condition options
      @@flow_condition = options
    end

    def flow_group group, *states
      @@flow_groups ||= {}
      states.each { |state| @@flow_groups[state] = group }
    end

    def flow_groups
      @@flow_groups
    end
  end

  def flow_group group
    self.class.flow_groups[state_symbol params] == group || params[:state].try(:start_with?, group.to_s)
  end

  def next_path(user, options={})
    next_location(user, :path, options)
  end

  def next_url(user, options={})
    next_location(user, :url, options)
  end

  def next_immediate_path(user, options={})
    next_location(user, :path, options, true)
  end

  def delayed_flow
    redirect_to next_location(@user, :url, params, true)
  end

  def flow
    render "flow/#{params[:state]}"
  end

  def direct_url(user, options={})
    next_location(user, :url, options, true, true)
  end

  def flow_reachable?(user, options={})
    options_with_params = add_params(options)
    possible_transitions = possible_transitions(options_with_params)
    valid_transition(possible_transitions, user)
  end

  private
  def next_location(user, type, options, immediate=false, ignore_from=false)
    options_with_params = add_params(options)
    possible_transitions = possible_transitions(options_with_params, ignore_from)
    if possible_transitions.size <= 1 || immediate
      valid_location(user, type, valid_transition(possible_transitions, user), options.except(:to))
    else
      send("delayed_flow_user_#{type}", user, options_with_params)
    end
  end

  def valid_location(user, type, valid_transition, options)
    if valid_transition
      send("#{valid_transition[:path] or 'flow_user'}_#{type}", user, options.merge(state: valid_transition[:to]))
    else
      send("user_#{type}", user)
    end
  end

  def valid_transition(transitions, user)
    transitions.detect { |t| evaluate_condition(user, t, :if) && evaluate_condition(user, t, :unless) }
  end

  def evaluate_condition user, transition, type
    [transition[type]].flatten.compact.all? do |method|
      user.respond_to?(method) && (type == :if ? user.send(method) : !user.send(method))
    end
  end

  def possible_transitions(options, ignore_from=false)
    self.class.flows.select do |t|
      (ignore_from || !t.has_key?(:from) ||
          [t[:from]].flatten.any? { |from| from == state_symbol(options) }
      ) &&
          (options[:to].nil? || t[:to] == options[:to])
    end
  end

  def state_symbol options
    options[:state].try :to_sym
  end

  def add_params(options)
    params.slice(:to, :state).merge(options)
  end
end
