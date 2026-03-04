require "./spec_helper"

describe Crab::Ansi_Parser do
  it "parses named colors" do
    parser = Crab::Ansi_Parser.new("full")
    result = parser.parse("#[red]text")
    result.should contain("\e[38;2;255;0;0mtext")
    result.should end_with("\e[0m")
  end

  it "parses hex colors" do
    parser = Crab::Ansi_Parser.new("full")
    result = parser.parse("#[#00FF00]green")
    result.should contain("\e[38;2;0;255;0mgreen")
  end

  it "parses RGB colors" do
    parser = Crab::Ansi_Parser.new("full")
    result = parser.parse("#[0,0,255]blue")
    result.should contain("\e[38;2;0;0;255mblue")
  end

  it "parses background colors" do
    parser = Crab::Ansi_Parser.new("full")
    result = parser.parse("#[red, bg]background")
    result.should contain("\e[48;2;255;0;0mbackground")
  end

  it "handles additive colors" do
    parser = Crab::Ansi_Parser.new("full")
    result = parser.parse("#[red]red #[white, bg]whitebg")
    # Red text
    result.should contain("\e[38;2;255;0;0mred ")
    # White background + Red text (Colorize.with is stateful)
    result.should contain("\e[38;2;255;0;0m\e[48;2;255;255;255mwhitebg")
  end

  it "respects return_to_default" do
    parser = Crab::Ansi_Parser.new("full")
    result = parser.parse("#[red]text", return_to_default: false)
    result.should_not end_with("\e[0m")
  end

  it "respects Colorize.enabled = false" do
    Colorize.enabled = false
    parser = Crab::Ansi_Parser.new("full")
    result = parser.parse("#[red]text")
    result.should eq("text")
    Colorize.enabled = true # Reset for other tests
  end

  it "handles color mode downgrades (256)" do
    parser = Crab::Ansi_Parser.new("256")
    result = parser.parse("#[255,0,0]red")
    # Red is 255, 0, 0
    # 16 + (36 * (255 // 51)) + (6 * (0 // 51)) + (0 // 51)
    # 16 + (36 * 5) + 0 + 0 = 16 + 180 = 196
    result.should contain("\e[38;5;196mred")
  end
end
