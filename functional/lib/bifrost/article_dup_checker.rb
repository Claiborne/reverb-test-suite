require 'set'

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

end
