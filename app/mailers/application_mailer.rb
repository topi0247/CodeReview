# frozen_string_literal: true

# app/mailers/application_mailer.rb

# ApplicationMailer handles the application's mailers.
class ApplicationMailer < ActionMailer::Base
  default from: 'from@example.com'
  layout 'mailer'
end
