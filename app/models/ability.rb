class Ability
  include CanCan::Ability

  def initialize(user)
    user ||= User.new
    case user.role
    when 'admin'
      can :manage, :all
    when 'user'
      can :read, Project
      can :read, User, id: user.id
      can :update, User, id: user.id
      # Puedes agregar más permisos específicos aquí
    else
      # Invitado/no autenticado
      can :read, Project
    end
  end
end
