# frozen_string_literal: true

class Base
  private

  def cmd_exec(command)
    print 'Command: '.green
    puts command.to_s.yellow
    system(command)
  end
end
