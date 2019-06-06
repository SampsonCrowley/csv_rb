class Notifier < ActionMailer::Base
  default :from => 'noreply@company.com'

  def instructions(user)
    @user = user

    # normal syntax
    csv = render_to_string handlers: [:csvrb], template: 'users/send_instructions', layout: false, formats: [:csv]
    attachments["user_#{user.id}.csv"] = {mime_type: Mime[:csv], content: csv}

    mail :to => user.email, :subject => 'Instructions'
  end

end