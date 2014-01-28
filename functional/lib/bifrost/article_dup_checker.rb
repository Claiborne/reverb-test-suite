require 'set'
require 'digest/md5'

module ArticleDupChecker

  MAX_CLOSENESS = 0.9
  TOKENIZE_RE = /[a-z][a-z0-9\-&]*/

  # given a list of document objects, return all duplicate or near duplicate pairs.
  def duplicates_or_near_duplicates(datas, closeness = MAX_CLOSENESS)
    duplicates_or_near_duplicates_recur(datas, [], closeness)
  end

  private
  
    def title_and_summary(data)
      title = ''
      header = data['header'] || {}
      title = header['value'] || title
      summary = ''
      summary = data['summary'] || summary
      [title, summary].join(' ')
    end

    def coca_tokenize(s)
      s.downcase.scan(TOKENIZE_RE)
    end 

    def token_set(s)
      Set.new(coca_tokenize(s))
    end
    
    def jaccard_similarity(s1, s2)
      i = s1.intersection(s2).size
      u = s1.union(s2).size
      u == 0 ? 0.0 : i.to_f/u
    end

    def data_to_set(data)
      token_set(title_and_summary(data))
    end

    def are_duplicates_or_near_duplicates(data1, data2, closeness = MAX_CLOSENESS)
      jaccard_similarity(data_to_set(data1), data_to_set(data2)) >= closeness
    end
    
    def duplicates_or_near_duplicates_recur(datas, accum, closeness = MAX_CLOSENESS)
      return accum if datas.size <= 1
      data1 = datas.first
      rest = datas[1..-1]
      duplicates = rest.find_all{|data2| are_duplicates_or_near_duplicates(data1, data2, closeness)}.map{|d| [data1, d]}
      duplicates_or_near_duplicates_recur(rest, accum + duplicates, closeness)
    end
    
    # exact duplicates by content — but not by content id
    def exact_duplicates(datas)
      digests = Hash.new
      datas.each do |data|
        digest = Digest::MD5.hexdigest(title_and_summary(data))
        digests.include?(digest) ? (digests[digest] << data) : (digests[digest] = [data])
      end
      digests.values.map{|v| (v.size > 1 && v.map{|d| d['contentId']}.uniq.size > 1) ? v : nil}.compact
    end
    
    # exact duplicates by content id, but must be at a certain distance 
    # from each other
    def exact_duplicates_by_content_id(datas, at_least=3)
      datas.zip(Range.new(1,datas.size)).
      map{|a,i| [a['contentId'],i]}.
      group_by{|a,i| a}.
      map{|k,v| v.size > 1 ? v : nil}.compact.
      map{|l| [l[0][0], l.map{|x| x[1]}, l.map{|x| x[1]}.max-l.map{|x| x[1]}.min]}.
      map{|k, is, d| d >= at_least ? [k, is, d] : nil}.compact
    end
    
end
