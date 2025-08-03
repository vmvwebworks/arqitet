import { Controller } from "@hotwired/stimulus"
import ApexCharts from "apexcharts"

// Controlador de gráficos usando ApexCharts
export default class extends Controller {
  static values = { 
    type: String,
    data: Object,
    options: Object,
    height: String
  }

  connect() {
    this.renderChart()
  }

  disconnect() {
    if (this.chart) {
      this.chart.destroy()
    }
  }

  renderChart() {
    const chartType = this.typeValue
    const chartData = this.dataValue
    const customOptions = this.optionsValue || {}
    const height = this.heightValue || "300px"

    let options = {
      chart: {
        type: this.getApexChartType(chartType),
        height: parseInt(height),
        toolbar: {
          show: false
        }
      },
      theme: {
        mode: 'light'
      },
      ...customOptions
    }

    // Configurar datos según el tipo de gráfico
    if (chartType === 'line' || chartType === 'bar') {
      options = this.configureLineBarChart(options, chartData)
    } else if (chartType === 'pie') {
      options = this.configurePieChart(options, chartData)
    }

    this.chart = new ApexCharts(this.element, options)
    this.chart.render()
  }

  getApexChartType(type) {
    const typeMap = {
      'line': 'line',
      'bar': 'bar',
      'pie': 'pie',
      'area': 'area',
      'column': 'bar'
    }
    return typeMap[type] || 'line'
  }

  configureLineBarChart(options, data) {
    if (Array.isArray(data) && data.length > 0 && data[0].name) {
      // Datos múltiples con series
      options.series = data.map(serie => ({
        name: serie.name,
        data: Object.entries(serie.data).map(([key, value]) => ({
          x: key,
          y: value
        }))
      }))
    } else {
      // Datos simples
      options.series = [{
        name: 'Datos',
        data: Object.entries(data).map(([key, value]) => ({
          x: key,
          y: value
        }))
      }]
    }

    options.xaxis = {
      type: 'category'
    }

    return options
  }

  configurePieChart(options, data) {
    options.series = Object.values(data)
    options.labels = Object.keys(data)
    return options
  }
}
