module MicropostsHelper

  def wrap(content)
    sanitize(raw(content.split.map{ |s| wrap_long_string(s) }.join(' ')))
  end

  private

    def wrap_long_string(text, max_width = 30)
    #Long lines usually wrap at spaces between words, but in languages without spaces between words (like Thai), 
    #sentences may appear as if they were one continuous word. Zero‐width spaces put “invisible spaces” 
    #between words where they can wrap to the next line. Zero‐width spaces divide long sequences of characters 
    #into smaller units that may wrap from one line to the next.
      zero_width_space = "&#8203;"
      regex = /.{1,#{max_width}}/
      (text.length < max_width) ? text : 
                                  text.scan(regex).join(zero_width_space)
    end
end