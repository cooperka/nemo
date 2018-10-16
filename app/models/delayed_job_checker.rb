# frozen_string_literal: true

# Checks if DelayedJob is running. Used in ping and operations controllers.
class DelayedJobChecker
  def running?
    pid_from_file_is_running?("tmp/pids/delayed_job.pid")
  end

  private

  def pid_from_file_is_running?(path)
    Process.kill(0, File.read(Rails.root.join(path)).to_i) && true
  rescue Errno::ENOENT, Errno::ESRCH
    false
  end
end
