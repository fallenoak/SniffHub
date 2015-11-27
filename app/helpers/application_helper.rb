module ApplicationHelper
  def form_authenticity_tag
    tag(:input, type: 'hidden', name: request_forgery_protection_token.to_s, value: form_authenticity_token)
  end

  def field_error(record, attribute)
    return if record.errors[attribute].empty?
    content_tag(:div, "#{record.errors.full_messages_for(attribute).first}.", class: 'field-error')
  end
end
