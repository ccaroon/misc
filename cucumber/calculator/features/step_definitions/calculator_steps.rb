Given /^the input "([^"]*)"$/ do |arg1|
    @input = arg1;
end

When /^the calculator is run$/ do
    @output = `~/src/cucumber/calculator/calc.rb #{@input}`;
    @output.chomp!;
    raise 'Command failed!' unless $?.success?;
end

Then /^the output should be "([^"]*)"$/ do |arg1|
    @output.should == arg1;
end

Given /^the input N\/(\d+)$/ do |arg1|
    arg1.to_i.should == 0;
end

Then /^the calculator should throw a division by zero error$/ do
    @output.should =~ /ZeroDivisionError/;
end

