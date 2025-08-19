class TaskDependency < ApplicationRecord
  belongs_to :predecessor_task, class_name: "ProjectTask"
  belongs_to :successor_task, class_name: "ProjectTask"

  validates :dependency_type, presence: true
  validates :predecessor_task_id, uniqueness: { scope: :successor_task_id }

  validate :cannot_create_circular_dependency
  validate :tasks_belong_to_same_project

  enum dependency_type: {
    finish_to_start: "finish_to_start",     # La predecesora debe terminar antes que inicie la sucesora
    start_to_start: "start_to_start",       # Ambas tareas inician al mismo tiempo
    finish_to_finish: "finish_to_finish",   # Ambas tareas terminan al mismo tiempo
    start_to_finish: "start_to_finish"      # La predecesora inicia cuando termina la sucesora
  }

  def dependency_type_spanish
    case dependency_type
    when "finish_to_start" then "Fin a Inicio"
    when "start_to_start" then "Inicio a Inicio"
    when "finish_to_finish" then "Fin a Fin"
    when "start_to_finish" then "Inicio a Fin"
    else "Desconocido"
    end
  end

  private

  def cannot_create_circular_dependency
    return unless predecessor_task && successor_task

    # No puede ser dependiente de si misma
    if predecessor_task_id == successor_task_id
      errors.add(:successor_task, "no puede depender de si misma")
      return
    end

    # Verificar dependencias circulares
    if creates_circular_dependency?
      errors.add(:base, "esta dependencia crearía un ciclo circular")
    end
  end

  def tasks_belong_to_same_project
    return unless predecessor_task && successor_task

    if predecessor_task.project_id != successor_task.project_id
      errors.add(:base, "las tareas deben pertenecer al mismo proyecto")
    end
  end

  def creates_circular_dependency?
    visited = Set.new
    stack = [ successor_task_id ]

    while stack.any?
      current_id = stack.pop
      return true if current_id == predecessor_task_id
      next if visited.include?(current_id)

      visited.add(current_id)

      # Agregar todas las tareas que dependen de la actual
      TaskDependency.where(predecessor_task_id: current_id)
                   .pluck(:successor_task_id)
                   .each { |id| stack.push(id) }
    end

    false
  end
end
