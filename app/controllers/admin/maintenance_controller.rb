class Admin::MaintenanceController < Admin::BaseController
  def toggle
    maintenance_file = Rails.root.join("tmp", "maintenance_mode")
    if File.exist?(maintenance_file)
      File.delete(maintenance_file)
      flash[:notice] = "Modo mantenimiento desactivado"
    else
      File.write(maintenance_file, "on")
      flash[:notice] = "Modo mantenimiento activado"
    end
    redirect_to admin_path
  end
end
