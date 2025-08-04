module SubscriptionsHelper
  def subscription_status_badge(subscription)
    case subscription.status
    when "active"
      content_tag :span, "Activa", class: "inline-flex px-2 py-1 rounded-full text-xs font-medium bg-green-100 text-green-800"
    when "trialing"
      content_tag :span, "Periodo de prueba", class: "inline-flex px-2 py-1 rounded-full text-xs font-medium bg-blue-100 text-blue-800"
    when "canceled"
      content_tag :span, "Cancelada", class: "inline-flex px-2 py-1 rounded-full text-xs font-medium bg-red-100 text-red-800"
    when "past_due"
      content_tag :span, "Pago atrasado", class: "inline-flex px-2 py-1 rounded-full text-xs font-medium bg-yellow-100 text-yellow-800"
    else
      content_tag :span, subscription.status.humanize, class: "inline-flex px-2 py-1 rounded-full text-xs font-medium bg-gray-100 text-gray-800"
    end
  end

  def plan_badge(plan)
    if plan.free?
      content_tag :span, "Gratuito", class: "inline-flex px-2 py-1 rounded-full text-xs font-medium bg-gray-100 text-gray-800"
    elsif plan.name.downcase.include?("pro")
      content_tag :span, "Pro", class: "inline-flex px-2 py-1 rounded-full text-xs font-medium bg-blue-100 text-blue-800"
    else
      content_tag :span, plan.name, class: "inline-flex px-2 py-1 rounded-full text-xs font-medium bg-purple-100 text-purple-800"
    end
  end

  def next_billing_date(subscription)
    return "N/A" if subscription.subscription_plan.free?
    return "N/A" unless subscription.current_period_end

    subscription.current_period_end.strftime("%d de %B de %Y")
  end
end
