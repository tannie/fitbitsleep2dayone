#!/usr/bin/ruby
require "json"
require "date"
timezone="Europe/Amsterdam"
json_from_file = File.read(ARGV[0])
fitbit = JSON.parse(json_from_file) 
thefile = ARGV[0]

if ARGV.length != 1
  puts "We need exactly one argument"
  exit
end

def time_conversion(minutes)
    hours = minutes / 60
    rest = minutes % 60
    #minutes = format('%02d', rest)
    return "#{hours}h #{rest}m"
end

def sleep_percentage(sleep1, total)
    percentagesleep = (sleep1*100) / total
    return percentagesleep
end

fitbit['sleep'].each do |day|
  puts day['dateOfSleep']
  puts day['type']
  thedate = day['dateOfSleep']
  starttime = DateTime.strptime(day['startTime'], '%Y-%m-%dT%H:%M:%S')
  endtime = DateTime.strptime(day['endTime'], '%Y-%m-%dT%H:%M:%S')
      postTextComplete = "# Sleep log #{thedate}: #{starttime.strftime('%H:%M')} - #{endtime.strftime('%H:%M')} "
  if day['isMainSleep']
    postTextComplete.concat("\n\n")
  else
    postTextComplete.concat(" (nap)\n\n")
  end
  totalminutes = day['minutesAsleep']  
  postTextComplete.concat("Total time in bed: #{time_conversion(day['timeInBed'])}\n\n")
  postTextComplete.concat("## Time asleep: #{time_conversion(day['minutesAsleep'])}\n\n")
  if day['type'] == "stages"
    postTextComplete.concat("Times awake: #{day['levels']['summary']['wake']['count']}\n")
    awakeminutes = day['levels']['summary']['wake']['minutes']
    totalminutes = day['minutesAsleep'] + awakeminutes
    remminutes = day['levels']['summary']['rem']['minutes']
    deepminutes = day['levels']['summary']['deep']['minutes']
    lightminutes = day['levels']['summary']['light']['minutes']
    postTextComplete.concat("Awake: #{time_conversion(awakeminutes)} (#{sleep_percentage(awakeminutes, totalminutes)}%)\n")
    postTextComplete.concat("Rem sleep: #{time_conversion(remminutes)} (#{sleep_percentage(remminutes, totalminutes)}%)\n")
    postTextComplete.concat("Light sleep: #{time_conversion(lightminutes)} (#{sleep_percentage(lightminutes, totalminutes)}%)\n") 
    postTextComplete.concat("Deep sleep: #{time_conversion(deepminutes)} (#{sleep_percentage( deepminutes, totalminutes)}%)\n") 
  else
    postTextComplete.concat("Times awake: #{day['levels']['summary']['awake']['count']}\n")
        postTextComplete.concat("Awake: #{time_conversion(day['levels']['summary']['awake']['minutes'])}\n")
        postTextComplete.concat("Times restless: #{day['levels']['summary']['restless']['count']}\n")
    postTextComplete.concat("Restless: #{time_conversion(day['levels']['summary']['restless']['minutes'])}\n")
  end
  
 newdate="#{endtime.strftime('%Y-%m-%d %H:%M')}"
  puts postTextComplete
  puts `echo "#{postTextComplete}" | dayone2 new -t fitbit sleep  -j Fitbit --date='#{newdate}' -z '#{timezone}'`;
end
