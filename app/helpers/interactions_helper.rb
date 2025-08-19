module InteractionsHelper
  def interaction_type_icon_svg(type)
    icons = {
      "call" => "M2 3a1 1 0 011-1h2.153a1 1 0 01.986.836l.74 4.435a1 1 0 01-.54 1.06l-1.548.773a11.037 11.037 0 006.105 6.105l.774-1.548a1 1 0 011.059-.54l4.435.74a1 1 0 01.836.986V17a1 1 0 01-1 1h-2C7.82 18 2 12.18 2 5V3z",
      "email" => "M2.003 5.884L10 9.882l7.997-3.998A2 2 0 0016 4H4a2 2 0 00-1.997 1.884z M18 8.118l-8 4-8-4V14a2 2 0 002 2h12a2 2 0 002-2V8.118z",
      "meeting" => "M13 6a3 3 0 11-6 0 3 3 0 016 0zM5 16v-1a3 3 0 116 0v1H5z M18 8a3 3 0 11-6 0 3 3 0 016 0zM14 20v-1a5.972 5.972 0 00-.75-2.906A3.005 3.005 0 0119 15v3a2 2 0 01-2 2h-3z",
      "note" => "M11 5H6a2 2 0 00-2 2v11a2 2 0 002 2h11a2 2 0 002-2v-5m-1.414-9.414a2 2 0 112.828 2.828L11.828 15H9v-2.828l8.586-8.586z",
      "proposal" => "M9 12h6m-6 4h6m2 5H7a2 2 0 01-2-2V5a2 2 0 012-2h5.586a1 1 0 01.707.293l5.414 5.414a1 1 0 01.293.707V19a2 2 0 01-2 2z",
      "contract" => "M9 12l2 2 4-4m6 2a9 9 0 11-18 0 9 9 0 0118 0z"
    }

    path = icons[type] || icons["note"]
    content_tag(:svg, class: "w-5 h-5", fill: "currentColor", viewBox: "0 0 20 20") do
      content_tag(:path, "", d: path)
    end
  end

  def format_interaction_date(date)
    return "" unless date

    if date.today?
      "Hoy a las #{date.strftime('%H:%M')}"
    elsif date.yesterday?
      "Ayer a las #{date.strftime('%H:%M')}"
    elsif date >= 1.week.ago
      date.strftime("%A a las %H:%M")
    else
      date.strftime("%d/%m/%Y a las %H:%M")
    end
  end
end
