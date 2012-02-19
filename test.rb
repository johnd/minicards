#!/usr/bin/env ruby

require_relative './background.rb'

Background.new( :generator => BlurredBigPixel.new ).generate.save
