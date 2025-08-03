class Admin::UsersController < Admin::BaseController
  before_action :set_user, only: [:show, :edit, :update, :destroy]

  def index
    # Filtros
    @filter_fields = [
      {label: 'Rol', name: 'role', type: :select, options: User.distinct.pluck(:role).compact.map { |r| {label: r, value: r} }},
      {label: 'Nombre', name: 'full_name', type: :text},
      {label: 'Email', name: 'email', type: :text}
    ]
    users = User.all
    users = users.where(role: params[:role]) if params[:role].present?
    users = users.where('full_name ILIKE ?', "%#{params[:full_name]}%") if params[:full_name].present?
    users = users.where('email ILIKE ?', "%#{params[:email]}%") if params[:email].present?
    @users = users.order(created_at: :desc)
    @rows = @users.map do |user|
      [
        view_context.link_to(user.email, view_context.admin_user_path(user), class: 'hover:underline text-gray-900 font-medium'),
        user.full_name,
        user.role
      ]
    end
    @actions = lambda do |row|
      user = @users.detect { |u| u.email == ActionView::Base.full_sanitizer.sanitize(row[0].to_s) }
      view_context.safe_join([
        view_context.link_to('Editar', view_context.edit_admin_user_path(user), class: 'btn btn-sm btn-secondary text-gray-800 hover:text-gray-900 border-gray-500 hover:border-gray-700'),
        view_context.button_to('Eliminar', view_context.admin_user_path(user), method: :delete, data: { confirm: '¿Seguro?' }, class: 'btn btn-sm btn-danger text-red-600 hover:text-red-800 border-red-500 hover:border-red-700')
      ], ' ')
    end
  end

  def show
  end

  def new
    @user = User.new
  end

  def create
    @user = User.new(user_params)
    if @user.save
      redirect_to admin_user_path(@user), notice: 'Usuario creado correctamente.'
    else
      render :new
    end
  end

  def edit
  end

  def update
    if @user.update(user_params)
      redirect_to admin_user_path(@user), notice: 'Usuario actualizado.'
    else
      render :edit
    end
  end

  def destroy
    @user.destroy
    redirect_to admin_users_path, notice: 'Usuario eliminado.'
  end

  private

  def set_user
    @user = User.friendly.find(params[:id])
  end

  def user_params
    params.require(:user).permit(:email, :name, :role, :password, :password_confirmation)
  end
end
