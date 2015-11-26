module ApplicationHelper
  def form_authenticity_tag
    tag(:input, type: 'hidden', name: request_forgery_protection_token.to_s, value: form_authenticity_token)
  end
end
