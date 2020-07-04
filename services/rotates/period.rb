# frozen_string_literal: true

module Rotates
  class Period
    def initialize(type = nil)
      @type = type
    end

    def call
      default_periods if type.nil?
    end

    private

    attr_reader :type

    def default_periods # rubocop:disable Metrics/MethodLength
      [
        { start: 96_422_400, stop: 9_642_240_000_000, count: 0 },
        { start: 64_281_601, stop: 96_422_400, count: 1 }, # 3 year
        { start: 32_140_801, stop: 64_281_600, count: 1 }, # 2 year
        { start: 29_462_401, stop: 32_140_800, count: 1 }, # 12 month
        { start: 26_784_001, stop: 29_462_400, count: 1 }, # 11 month
        { start: 24_105_601, stop: 26_784_000, count: 1 }, # 10 month
        { start: 21_427_201, stop: 24_105_600, count: 1 }, # 9 month
        { start: 18_748_801, stop: 21_427_200, count: 1 }, # 8 month
        { start: 16_070_401, stop: 18_748_800, count: 1 }, # 7 month
        { start: 13_392_001, stop: 16_070_400, count: 1 }, # 6 month
        { start: 10_713_601, stop: 13_392_000, count: 1 }, # 5 month
        { start: 8_035_201, stop: 10_713_600, count: 1 }, # 4 month
        { start: 5_356_801, stop: 8_035_200, count: 1 }, # 3 month
        { start: 2_678_401, stop: 5_356_800, count: 1 }, # 2 month
        { start: 1_814_401, stop: 2_678_400, count: 1 }, # 4 week
        { start: 1_209_601, stop: 1_814_400, count: 1 }, # 3 week
        { start: 604_801, stop: 1_209_600, count: 1 }, # 2 week
        { start: 172_801, stop: 604_800, count: 5 }, # 2..7 days
        { start: 0, stop: 172_800, count: 2 } # 1..2 days
      ]
    end
  end
end
