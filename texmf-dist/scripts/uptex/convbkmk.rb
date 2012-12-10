#!/usr/bin/ruby
# -*- coding: utf-8 -*-

=begin

convbkmk Ver.0.01

= License

convbkmk

Copyright (c) 2009-2011 Takuji Tanaka

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.

= History

2009.08.02   0.00  Initial version.
2011.05.02   0.01  Bug fix: BOM was not correct.

=end

Version = "0.01"

require "optparse"

if RUBY_VERSION >= "1.9"
  $RUBY_M17N = true

  class String
    def to_utf16be(enc)
      self.force_encoding(enc.current).encode('UTF-16BE')
    end
  end
else
  $RUBY_M17N = false

  require "jcode" # for method each_char
  require "kconv"
  class String
    def to_utf16be(enc)
      self.kconv(Kconv::UTF16, enc.kconv_enc)
    end
    def ascii_only?
      return self !~ /[\x80-\xFF]/n
    end
    def valid_encoding?
      tmp = "\"" + self + "\""
      tmp.gsub!("\\(","\\\\\\(")
      tmp.gsub!("\\)","\\\\\\)")
      tmp.gsub!("\n","\\n").gsub!("\r","\\r")
      return tmp == self.inspect
    end
    def force_encoding(enc)
      if (enc =~ /^(Shift_JIS|EUC-JP|UTF-8)/i)
        $KCODE=enc
      end
      return self
    end
  end
end

class TeXEncoding
  attr_accessor :current, :option, :status, :is_8bit, :kconv_enc
  attr_reader :list

  def initialize
    @current = false
    @option = false
    @status = false
    @is_8bit = false
    @list = ['Shift_JIS', 'EUC-JP', 'UTF-8']
    if !$RUBY_M17N
      @kconv_enc = nil
      @kconv_list = {'Shift_JIS' => Kconv::SJIS,
                     'EUC-JP' => Kconv::EUC,
                     'UTF-8' => Kconv::UTF8}
    end
  end

  def set_process_encoding(enc)
    if @status == 'fixed'
      raise 'dupulicate definition'
    end
    if enc == 'guess'
      @option = 'guess'
      @status = 'guess'
    else
      @current = enc
      @option = enc
      @status = 'fixed'
      if !$RUBY_M17N
        @kconv_enc = @kconv_list[enc]
      end
    end
    return enc
  end
end
enc = TeXEncoding.new

OptionParser.new do |opt|
  opt.on('-e', '--euc-jp',
         'set pTeX internal encoding to EUC-JP') {|v|
    enc.set_process_encoding('EUC-JP')
  }
  opt.on('-s', '--shift_jis',
         'set pTeX internal encoding to Shift_JIS') {|v|
    enc.set_process_encoding('Shift_JIS')
  }
  opt.on('-u', '--utf-8',
         'set upTeX internal encoding to UTF-8') {|v|
    enc.set_process_encoding('UTF-8')
  }
  opt.on('-g', '--guess',
         'guess pTeX/upTeX internal encoding') {|v|
    enc.set_process_encoding('guess')
  }
  enc_alias = Hash.new
  enc.list.each { |e|
    enc_alias[e] = e
    enc_alias[e[0]] = e
    enc_alias[e.downcase] = e
  }
  opt.on('--enc=ENC', enc_alias,
         'set pTeX/upTeX internal encoding to ENC') {|v|
    enc.set_process_encoding(v)
  }
  opt.banner += " file0.ps [file1.ps ...]\n" \
    + opt.banner.sub('Usage:','      ') + ' < in_file.ps > out_file.ps'

  opt.parse!
end

# default encoding
if enc.status == false
  enc.set_process_encoding('UTF-8')
end


def try_guess_encoding(line, enc)
  return 'US-ASCII' if line.ascii_only?

  valid_enc = false
  count = 0
  enc.list.each { |e|
    if line.dup.force_encoding(e).valid_encoding?
      count += 1
      valid_enc = e
    end
  }
  if count == 1
    enc.set_process_encoding(valid_enc)
    return valid_enc
  elsif count > 1
    return false # ambiguous
  else
    raise 'Cannot guess encoding!'
  end
end


def check_parentheses_balance(line, enc)
  depth = 0
  count = 0
  tmp_prev = ''
  tmp_rest = line

  if enc.status == 'guess'
    if tmp_enc = try_guess_encoding(line, enc)
      # succeeded in guess or ascii only
      tmp_rest = line.force_encoding(tmp_enc)
    else
      # ambiguous
      enc.is_8bit = true
      depth = 1
      count = 0
      tmp_prev = ''
      tmp_rest = tmp_rest.force_encoding('ASCII-8BIT')
      return depth, count, tmp_prev, tmp_rest
    end
  else
    tmp_enc = enc.current
    tmp_rest = tmp_rest.force_encoding(tmp_enc)
    unless tmp_rest.valid_encoding?
      # illegal input
      $stdout = STDERR
      p 'parameters: '
      p enc.status
      p enc.option
      p enc.current
      p enc.is_8bit
      if !$RUBY_M17N
        p tmp_rest.inspect
        p tmp_rest
      end
      p line
      raise 'encoding is not consistent'
    end
  end

  while tmp_rest.length>0 do
    if    (tmp_rest =~ /\A(\\\(|\\\)|[^()])*(\(|\))/) # parenthis
      if $2 == '('
        depth += 1
        count += 1
      else
        depth -= 1
      end
      tmp_prev += $&
      tmp_rest = $'
    else
      tmp_prev += tmp_rest
      tmp_rest = ''
    end
    if depth<1
      break
    end
  end
  return depth, count, tmp_prev, tmp_rest
end


def conv_string_to_utf16be(line, enc)
  if line !~ /(\()(.*)(\))/m
    raise 'illegal input!'
  end
  pre, tmp, post = $`, $2, $'

  if tmp.ascii_only?
    return line
  end

  conv = ''
  conv.force_encoding(enc.current)
  tmp.force_encoding(enc.current)
  while tmp.length>0 do
    if tmp =~ /\A[^\\]+/
      conv += $&
    elsif tmp =~ /\\([0-3][0-7][0-7])/
      conv += $RUBY_M17N ? $&.oct.chr('ASCII-8BIT') : $&.oct.chr
    elsif tmp =~ /\\([\r\n]{1,2})/
      # ignore
    elsif tmp =~ /\\[nrtbf]/
      conv += eval($&)
    elsif tmp =~ /\\(.)/
      conv += $1
    else
      raise 'unexpected input!'
    end
    tmp = $'
  end

  buf = 'FEFF' # BOM for UTF-16BE
  conv.each_char { |chr|
    if chr == "\r" || chr == "\n"
      buf += chr
    else
      chr.to_utf16be(enc).each_byte {|byte|
        buf += '%02X' % byte
      }
    end
  }
  return pre + '<' + buf + '>' + post
end


def file_treatment(ifile, ofile, enc)
  if $RUBY_M17N
    ifile.set_encoding('ASCII-8BIT')
    ofile.set_encoding('ASCII-8BIT')
  end

  line = ''
  while l = ifile.gets do
    line.force_encoding('ASCII-8BIT') if $RUBY_M17N
    line += l
    if (line !~ %r!(/Author|/Title|/Subject|/Keywords)! )
      ofile.print line
      line = ''
      next
    end

    ofile.print $`
    line = $& + $'
    depth, count, tmp_prev, tmp_rest \
      = check_parentheses_balance(line, enc)
    if depth<0
      raise 'illegal input!'
    elsif depth>0
      next
    elsif count==0
      next
    elsif count>0
      ofile.print conv_string_to_utf16be(tmp_prev, enc)
      line = tmp_rest
    else
      raise 'illegal input!'
    end

  end

  if enc.status == 'guess' && enc.is_8bit
    raise 'did not succeed in guess encoding!'
  end

  if line.length>0
    ofile.print line
  end
end


### main
if ARGV.size == 0
  ifile = STDIN
  ofile = STDOUT
  file_treatment(ifile, ofile, enc)
else
  ARGV.each {|fin|
    if (fin !~ /\.ps$/i)
      raise 'input file does not seem PS file'
    end
    fout = fin.gsub(/\.ps$/i, "-convbkmk#{$&}")
    open(fin, 'r') {|ifile|
      open(fout, 'w') {|ofile|
        file_treatment(ifile, ofile, enc)
      }
    }
  }
end


