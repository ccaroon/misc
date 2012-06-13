require './calc.rb';

Given /^the input "([^"]*)"$/ do |arg1|
    @input = arg1;
end

When /^the calculator is run$/ do
    @output = Calc.compute(@input);
end

Then /^the output should be "([^"]*)"$/ do |arg1|
    @output.to_i.should == arg1.to_i;
end
