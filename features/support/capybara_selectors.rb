require 'capybara'

Capybara.add_selector(:name) do
  xpath { |name| XPath.descendant[XPath.attr(:name) == name.to_s] }
end
