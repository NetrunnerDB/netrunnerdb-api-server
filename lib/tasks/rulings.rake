namespace :rulings do
  desc 'create JSON files from NRDB v1 rules export.'

  def text_to_id(t)
    t.downcase
      .unicode_normalize(:nfd)
      .gsub(/\P{ASCII}/, '')
      .gsub(/'s(\p{Space}|\z)/, 's\1')
      .split(/[\p{Space}\p{Punct}]+/)
      .reject { |s| s&.strip&.empty? }
      .join("_")
  end

  task :transform, [:json_dir] => [:environment] do |t, args|
    args.with_defaults(:json_dir => '/netrunner-cards-json/v2/')

    new_rulings_by_card_id = {}
    rulings = JSON.parse(File.read('/netrunner-cards-json/rulings.json'))
    rulings.each do |r|
      r['card_id'] = text_to_id(r['card_id'])
      # Identify ruling source id
      if not r.has_key?('ruling_source_id')
        puts 'No ruling source id'
        ruling_source_id = 'unknown'
        if r['question'].match?(/\[(UFAQ \d+)/)
          m = r['question'].match(/\[(UFAQ \d+)/)
          if m && m.captures.length == 1
            ruling_source_id = text_to_id(m.captures[0])
          end
        elsif r['question'].match?(/\[Michael Boggs\]/)
          ruling_source_id = 'michael_boggs'
        elsif r['question'].match?(/\[Damon Stone\]/)
          ruling_source_id = 'damon_stone'
        elsif r['question'].match?(/\[Official FAQ\]/)
          ruling_source_id = 'official_faq'
        else
          ruling_source_id = 'nsg_rules_team'
        end
        puts 'Discovered ruling_source_id %s' % ruling_source_id
        if ruling_source_id == 'unknown'
          puts r['question']
        end

        r['ruling_source_id'] = ruling_source_id
      else
        puts 'Has a ruling source id of %s' % r['ruling_source_id'] 
      end

      if r['question'].match?(/\?/) and r['question'].match(/\n> /)
          puts "Looks like a question: %s" % r['question']
          r.delete('text_ruling')

          q_and_a = r['question'].split(/\n> /)
          r['question'] = q_and_a[0]
          r['answer'] = q_and_a[1] 
      else
        r.delete('question')
        r.delete('answer')
      end

      if !new_rulings_by_card_id.has_key?(r['card_id'])
        new_rulings_by_card_id[r['card_id']] = []
      end
      new_rulings_by_card_id[r['card_id']] << r
    end

    new_rulings_by_card_id.each do |c, r|
      puts c 
      puts "======"
      File.write('/netrunner-cards-json/v2/rulings/%s.json' % c, "%s\n" % JSON.pretty_generate(r))
    end
  end
end
