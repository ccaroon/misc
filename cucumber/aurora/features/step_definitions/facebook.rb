require 'watir-webdriver';

Then /^the Facebook Like button should be displayed$/ do
  @browsers.each do |b|
    button = b.div(:id => 'fb_iframe_container').frame(:id => 'fbLikeIframe');
    button.should exist;
    
    url = b.url;
    button.src.should =~ /#{url}/;    
  end
end
