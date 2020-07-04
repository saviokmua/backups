# frozen_string_literal: true

require_relative '../services/base'
require_relative 'rotates/period'

class Rotate < Base
  def initialize(path, periods = nil)
    @path = path
    @periods = periods || ::Rotates::Period.new.call
  end

  def call
    periods.each do |period|
      objects = rotate_objects(period)
      remove_objects(objects, period)
    end
  end

  private

  attr_reader :path, :periods

  def rotate_objects(period, now_time = Time.new)
    res = {}
    Dir.entries(path).each do |object|
      next if %w[. ..].include?(object)

      year = object[0..3]
      month = object[5..6]
      day = object[8..9]
      hour = object[11..12]
      minute = object[14..15]
      second = object[17..18]
      next if year.nil? || month.nil? || day.nil? || hour.nil? || minute.nil? || second.nil?

      object_time = Time.new(year, month, day, hour, minute, second)
      seconds = (now_time - object_time).to_i
      res[seconds] = object if (period[:start].to_i..period[:stop].to_i).include?(seconds)
    end
    Hash[res.sort]
    res
  end

  def remove_objects(objects, period)
    objects = objects.values.reverse
    objects_count = objects.count

    return if objects_count <= period[:count]

    remove_count = objects_count - period[:count]

    (0..remove_count - 1).each do |i|
      remove_object(objects[i])
    end
  end

  def remove_object(object)
    cmd_exec "rm -r #{path}/#{object}"
  end
end
