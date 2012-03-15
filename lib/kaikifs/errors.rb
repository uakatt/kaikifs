# An Exception class indicating that Webauth Authentication failed
class WebauthAuthenticationError < StandardError
end

# An Exception class indicating that our environment is apparently in Maintenance Mode
class MaintenanceModeError < StandardError
end
