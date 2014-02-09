# -*- coding: utf-8 -*-
=begin


参考：(http://ruby-gnome2.sourceforge.jp/ja/hiki.cgi?gtk2-tut-entry)

=end
require 'gtk2'
load("ClassCrawler.rb")

window_width = 420
window_height = 230
$window2_width = 720
$window2_height = 400
$gallery_dir = "./image/human/"
$etc_dir = "./image/not_human/"

#サイズ変換；新しいwidthに合わせてheightを計算する
def heightCalc(old_w, old_h, new_w)
  new_h = ((new_w.to_f / old_w.to_f) * old_h.to_f)
  puts new_h
  return new_h
end

#サイズ変換；新しいheightに合わせてwidthを計算する
def widthCalc(old_w, old_h, new_h)
  new_w = ((new_h.to_f / old_h.to_f) * old_w.to_f)
  puts new_w
  return new_w
end

#表示する画像の大きさをウィンドウに合わせるように縦横比を保ったまま変換する。
def imageSizeTranslate(image, image_width, image_height)

  if  image_width > $window2_width && image_height > $window2_height
    width_diff = image_width - $window2_width
    height_diff = image_height - $window2_height
    if width_diff >= height_diff
      new_h = heightCalc(image_width, image_height, $window2_width)
      image.pixbuf = image.pixbuf.scale($window2_width, new_h)
    else
      new_w = widthCalc(image_width, image_height, $window2_height)
      image.pixbuf = image.pixbuf.scale(new_w, $window2_height)
    end
  elsif  image_height > $window2_height
    new_w = widthCalc(image_width, image_height, $window2_height)
    image.pixbuf = image.pixbuf.scale(new_w, $window2_height)
  elsif  image_width > $window2_width
    new_h = heightCalc(image_width, image_height, $window2_width)
    image.pixbuf = image.pixbuf.scale($window2_width, new_h)
  end
  return image
end

#ModalDialogを作成する。
#ダイアログ作成(参照:http://ruby-gnome2.sourceforge.jp/ja/hiki.cgi?gtk2-tut-dialog)
def createModalDialog(title, label, win, num_of_button)
  dialog = Gtk::Dialog.new(title, win, Gtk::Dialog::MODAL)
  dialog.window_position = Gtk::Window::POS_CENTER
  dialog.vbox.pack_start(Gtk::Label.new(label), true, true, 30)
  if num_of_button == 2
    dialog.add_button(Gtk::Stock::OK, Gtk::Dialog::RESPONSE_OK)
    dialog.add_button(Gtk::Stock::CANCEL, Gtk::Dialog::RESPONSE_CANCEL)
    dialog.default_response = Gtk::Dialog::RESPONSE_CANCEL
  elsif num_of_button == 1
    dialog.add_button(Gtk::Stock::OK, Gtk::Dialog::RESPONSE_OK)
    dialog.default_response = Gtk::Dialog::RESPONSE_OK
  else
    return nil
  end

  return dialog
end

window = Gtk::Window.new
window2 = Gtk::Window.new
vbox = Gtk::VBox.new(true, 10)
vbox2 = Gtk::VBox.new(true, 10)
hbox = Gtk::HBox.new(true, 20)


#image_1 = Gtk::Image.new("test.jpg")
image_1 = Gtk::Image.new

url_entry = Gtk::Entry.new
num_of_image_entry = Gtk::Entry.new

url_label = Gtk::Label.new("Set URL")
number_label = Gtk::Label.new("Set num")
button = Gtk::Button.new("Start Crawling")
gallery_button = Gtk::Button.new("Show Image")
quit_button = Gtk::Button.new("Close")

separator = Gtk::HSeparator.new
separator2 = Gtk::HSeparator.new
align = Gtk::Alignment.new(0.5, 0.5, 0, 0)
pbar = Gtk::ProgressBar.new

window.set_size_request(window_width, window_height)
window.title = "Main Controller"
window.set_window_position(Gtk::Window::POS_CENTER)
window.add(vbox)
window2.set_size_request($window2_width, $window2_height)
window2.title = "Image Gallery"
window.set_window_position(Gtk::Window::POS_CENTER)

vbox.pack_start(url_label, false, false, 5)
url_entry.max_length = 300
url_entry.select_region(0, -1)
vbox.pack_start(url_entry, false, false, 5)
vbox.pack_start(separator, false, false, 5)
vbox.pack_start(align, false, false, 5)
vbox.pack_start(separator2, false, false, 5)
align.add(pbar)

vbox.add(hbox)
hbox.pack_start(button, true, true, 10)
hbox.pack_start(gallery_button, true, true, 10)
vbox2.pack_start(number_label, false, false, 5)
vbox2.pack_start(num_of_image_entry, false, false, 5)
hbox.pack_start(vbox2, true, true, 10)
num_of_image_entry.select_region(0, -1)
num_of_image_entry.max_length = 5

vbox.pack_start(quit_button, false, false, 0)
quit_button.can_default = true
quit_button.grab_default

# image_1_width = image_1.pixbuf.width
# image_1_height = image_1.pixbuf.height
# image_1 = imageSizeTranslate(image_1, image_1_width, image_1_height)

window2.add(image_1)




#各種シグナルを登録する

window.signal_connect("destroy") do
  thread_1.kill
  thread_2.kill
  thread_3.kill
  Gtk.main_quit
end

window2.signal_connect("destroy") do
  Gtk.main_quit
end

url_entry.signal_connect("activate") do
  puts "Entry contents: #{url_entry.text}"
end


button.signal_connect("clicked") do
  uri = url_entry.text
  num_of_image = num_of_image_entry.text

  #入力された項目をチェックしどちらもOKならcl_flagは２になる
  cl_flag = 0
  if uri =~ /http:[^\"]*?/
    puts "uri is ok"
    cl_flag += 1
  else
    puts "invalid uri"
    alert_dialog_1 = createModalDialog("Error", "Invalid URL", window, 1)
    alert_dialog_1.signal_connect("response") do |widget, response|
      case response
      when Gtk::Dialog::RESPONSE_OK
        alert_dialog_1.destroy
      end
    end
    alert_dialog_1.show_all
  end

  if num_of_image =~ /^[0-9]+$/
    puts "number is ok"
    cl_flag += 1
  else
    puts "invalid number"
    alert_dialog_2 = createModalDialog("Error", "Invalid number", window, 1)
    alert_dialog_2.signal_connect("response") do |widget, response|
      case response
      when Gtk::Dialog::RESPONSE_OK
        alert_dialog_2.destroy
      end
    end
    alert_dialog_2.show_all
  end

  #項目が正しかった場合の処理
  if cl_flag == 2
    #既に存在しているファイル数を保存しておく。入力されたファイル数分の画像を集めるために初期値を知る必要がある
    tmp = Dir::entries($gallery_dir).size + Dir::entries($etc_dir).size
    exist_image_f = tmp.to_f
    print "exist_image_f = ", exist_image_f, "\n"

    #確認ダイアログ生成。
    start_dialog = createModalDialog("Start Crawling", "Start Crawling?", window, 2)
    start_dialog.signal_connect("response") do |widget, response|
      case response

      #OKの場合、Crawlerクラスのインスタンスを生成する。
      when Gtk::Dialog::RESPONSE_OK
        start_dialog.destroy
        button.set_sensitive(false)
        #スレッド1は画像のクロールを行う。
        thread_1 = Thread.start do
          loop {
            cl = Crawler.new(uri, num_of_image.to_i)
            result = cl.startCrawl
            if result == 0
              puts "正常終了"
              finish_dialog = createModalDialog("Finished Crawling", "Finished", window, 1)
              finish_dialog.signal_connect("response") do |widget, response|
                case response
                when Gtk::Dialog::RESPONSE_OK
                  finish_dialog.destroy
                end
              end
              finish_dialog.show_all
              button.set_sensitive(true)
              thread_1.join
              thread_2.join
            else
              puts "異常終了"
              button.set_sensitive(true)
              error_dialog = createModalDialog("Error", "Error Occurred", window, 1)
              error_dialog.signal_connect("response") do |widget, response|
                case response
                when Gtk::Dialog::RESPONSE_OK
                  error_dialog.destroy
                end
              #thread_1.kill
              thread_2.kill
              end
            end
          }
        end

        #スレッド2はダウンロードした画像数を計算し、プログレスバーを更新する。
        thread_2 = Thread.start do
          noi_f = num_of_image.to_f
          loop {
            tmp = Dir::entries($gallery_dir).size + Dir::entries($etc_dir).size
            num_f = tmp.to_f
            new_val = ((num_f - exist_image_f) / noi_f)
            print "new_val = ", new_val, "\n"
            if new_val > 1.0
              pbar.fraction = 1.0
              break
            end
            pbar.fraction = new_val
            sleep 3
          }
        end
      when Gtk::Dialog::RESPONSE_CANCEL
        start_dialog.destroy
        p "Cancel"
      end
    end
    start_dialog.show_all
  end
end

gallery_button.signal_connect("clicked") do
  gallery_button.set_sensitive(false)
  image_name_array = Array.new
  Dir::entries($gallery_dir).each do |file|
    if file =~ /.*?\.jpg/
      puts file
      image_name_array << file
    end
  end

  # $gallery_dir以下にあるjpg画像をスライドショーする
  thread_3 = Thread.start do
    image_name_array.each do |file|
      print "thread start [file] = ", file, "\n"
      file_path = $gallery_dir + file
      image_1.set_file(file_path)
      image_1 = imageSizeTranslate(image_1, image_1.pixbuf.width, image_1.pixbuf.height)
      sleep 5
    end
    gallery_button.set_sensitive(true)
  end
end

num_of_image_entry.signal_connect("activate") do
  puts "Entry contents: #{num_of_image_entry.text}"
end

quit_button.signal_connect("clicked") do
  Gtk.main_quit
end

window2.show_all
window.show_all


Gtk.main

