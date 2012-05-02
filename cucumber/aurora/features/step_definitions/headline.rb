Then /^the story headline is present$/ do
  @headlines = Array.new;
  @browsers.each do |b|
    headline = b.element(:class => 'entry-title');
    headline.should exist;
    @headlines.push headline;
  end
end

Then /^the font is larger than the story body$/ do
  @headlines.each do |h|
    h.tag_name.should == 'h1'
  end
end
