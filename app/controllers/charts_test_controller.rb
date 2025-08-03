class ChartsTestController < ApplicationController
  def index
    # Datos de prueba para los gráficos
    @visits_per_month = {
      'Ene 2025' => 15,
      'Feb 2025' => 25,
      'Mar 2025' => 30,
      'Abr 2025' => 20,
      'May 2025' => 35,
      'Jun 2025' => 40,
      'Jul 2025' => 45,
      'Ago 2025' => 10
    }
    
    @projects_per_month = {
      'Ene 2025' => 2,
      'Feb 2025' => 1,
      'Mar 2025' => 3,
      'Abr 2025' => 0,
      'May 2025' => 2,
      'Jun 2025' => 1,
      'Jul 2025' => 2,
      'Ago 2025' => 1
    }
    
    @visits_by_project = {
      'Casa Moderna' => 45,
      'Edificio Central' => 30,
      'Parque Residencial' => 25,
      'Torre Empresarial' => 20,
      'Centro Comercial' => 15
    }
  end
end
