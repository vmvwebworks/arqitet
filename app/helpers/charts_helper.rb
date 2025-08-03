module ChartsHelper
  def apex_chart(type, data, options = {})
    height = options.delete(:height) || "300px"
    chart_options = options.delete(:library) || {}

    # Generar ID único para el gráfico
    chart_id = "chart_#{SecureRandom.hex(4)}"

    content_tag :div, "",
      id: chart_id,
      data: {
        controller: "chart",
        chart_type_value: type.to_s,
        chart_data_value: data.to_json,
        chart_options_value: chart_options.to_json,
        chart_height_value: height
      },
      style: "height: #{height};"
  end

  def apex_chart_with_id(type, data, chart_id, options = {})
    height = options.delete(:height) || 300
    chart_options = options.delete(:library) || {}

    content_tag :div, "",
      id: chart_id,
      data: {
        controller: "chart",
        chart_type_value: type.to_s,
        chart_data_value: data.to_json,
        chart_options_value: chart_options.to_json,
        chart_height_value: height
      },
      style: "height: #{height}px;"
  end

  def line_chart(data, options = {})
    apex_chart(:line, data, options)
  end

  def render_line_chart(data, chart_id, options = {})
    apex_chart_with_id(:line, data, chart_id, options)
  end

  def bar_chart(data, options = {})
    apex_chart(:bar, data, options)
  end

  def render_bar_chart(data, chart_id, options = {})
    apex_chart_with_id(:bar, data, chart_id, options)
  end

  def pie_chart(data, options = {})
    apex_chart(:pie, data, options)
  end

  def render_pie_chart(data, chart_id, options = {})
    apex_chart_with_id(:pie, data, chart_id, options)
  end

  def area_chart(data, options = {})
    apex_chart(:area, data, options)
  end

  def column_chart(data, options = {})
    apex_chart(:column, data, options)
  end
end
