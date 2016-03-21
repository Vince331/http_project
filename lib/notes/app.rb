require 'notes'
class Notes
  formpath = File.realdirpath("views/root.html")
  FORM = File.read(formpath)
  notepath = File.realdirpath("views/notes.rb")
  NOTES = eval File.read(notepath)
  APP = Proc.new do |env|
    form = FORM

    # using that query array it returns notes that match the query
    query_string = env["QUERY_STRING"]
    if !query_string.empty?
      result = Notes.new(NOTES).match(query_string)
      form = result.join("<br>") + FORM
    elsif env["PATH_INFO"] == "/search?query="
      form = NOTES.join("<br>") + FORM
    else
      form = FORM
    end
    response_code = 200
    headers = {
      "Content-Type" => "text/html", "Content-Length" => form.length
    }
    body = [form]
    [response_code, headers, body]
  end
end
