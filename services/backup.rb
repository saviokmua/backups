# frozen_string_literal: true

require 'rubygems'
require 'net/ssh'
require 'date'
require 'colorize'
require_relative '../services/rotate'
require_relative '../services/base'

class Backup < Base
  def initialize(conf)
    @conf = conf
  end

  def call
    create_backup_folder
    backup_exec
    rotate_exec
    # backup database
    # @params[:backup][:objects][:databases].each do |db|
    #   backup_mysql db
    # end

    # exec_ssh "rm -r #{@params[:server][:tmp_dir]}"


  end

  private

  attr_reader :conf

  def backup_folder
    @_backup_folder ||= Time.new.strftime(Time.new.strftime('%Y-%m-%d_%H-%M-%S'))
  end

  def backup_full_path
    @_backup_full_path ||= "#{conf[:backup_path]}/#{backup_folder}"
  end

  def create_backup_folder
    cmd_exec "mkdir -p #{backup_full_path}"
    # exec_ssh "mkdir #{@params[:server][:tmp_dir]}"
  end

  def backup_exec
    conf[:paths].each do |path|
      backup_path(path)
    end
  end

  def backup_path(path)
    cmd_exec "tar czvf #{backup_full_path}/#{backup_file_name(path)}.tar.gz #{path}"
    # file = "#{@params[:server][:tmp_dir]}/#{get_folder_name(folder)}.tar.gz"
    # cmd = "sudo -s tar czvf #{file} #{folder}"
    # exec_ssh cmd
    # ftp_upload @params[:backup][:folder], file
    # ftp_upload2 folder, @params[:backup][:folder]
  end

  def backup_file_name(path)
    path.gsub '/', '_'
  end

  def rotate_exec
    return if conf[:rotates].nil?

    conf[:rotates].each do |rotate|
      next if rotate[:path].nil?

      ::Rotate.new(rotate[:path]).call
    end
  end

  def rotate(path, periods = nil); end

  def exec_ssh(cmd)
    puts "ssh_cmd: #{cmd}"
    ssh = Net::SSH.start(@params[:server][:ssh_host], @params[:server][:ssh_user], password: @params[:server][:ssh_password])
    res = ssh.exec!(cmd)
    ssh.close
    puts "ssh_rezult: #{res}"
  rescue StandardError
    puts "Unable to connect to #{@params[:server][:ssh_host]} using #{@params[:server][:ssh_user]}/#{@params[:server][:ssh_password]}"
  end

  def exec2
    @params[:backup][:rotates]&.each do |rotate_path|
      rotate rotate_path
    end
  end

  def backup_mysql(db)
    if db[:type] == 'mysql'
      file = "#{@params[:server][:tmp_dir]}/dump_#{db[:name]}.sql.gz"
      # cmd = "/usr/local/bin/mysqldump -u #{db[:user]} -p#{db[:password]} -f --default-character-set=utf8 --databases #{db[:name]} -i --hex-blob --quick > #{@params[:server][:tmp_dir]}/#{db[:name]}.sql"
      cmd = "sudo -s /usr/local/bin/mysqldump -u #{db[:user]} -p#{db[:password]} -f --default-character-set=utf8 --databases #{db[:name]} -i --hex-blob --quick  | gzip -c > #{file}"
      exec_ssh cmd
      ftp_upload @params[:backup][:folder], file
    end
  end

  def ftp_upload(to_folder, file)
    @params[:backup][:ftps].each do |ftp|
      cmd = "/usr/bin/lftp -u #{ftp[:user]},\"#{ftp[:password]}\" -e \"mkdir #{to_folder}; mput -O /#{to_folder}/ #{file};exit\" #{ftp[:host]}"
      exec_ssh cmd
      cmd = "rm #{file}"
      exec_ssh cmd
    end
  end

  def ftp_upload2(from_folder, to_folder)
    @params[:backup][:ftps].each do |ftp|
      cmd = "/usr/bin/lftp -u #{ftp[:user]},\"#{ftp[:password]}\" -e \"mkdir #{to_folder};exit\" #{ftp[:host]}"
      exec_ssh cmd
      cmd = "sudo -s tar czvf - #{from_folder} | ncftpput -u #{ftp[:user]} -p #{ftp[:password]} -c #{ftp[:host]} #{to_folder}/#{get_folder_name(from_folder)}.tar.gz"
      exec_ssh cmd
    end
  end
end
