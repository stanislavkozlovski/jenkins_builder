require 'terminal-notifier'

module Notifier
  class << self
    APP_TITLE = 'Builder'
    @@can_notify = TerminalNotifier.available?

    #
    # Issues a standard notification
    #
    def notify(msg)
      TerminalNotifier.notify(msg, title: APP_TITLE) if @@can_notify
    end

    #
    # Issues an error notification
    #
    def notify_error(msg)
      notify("❌[ERROR]❌ #{msg}") if @@can_notify
    end
  end
end
