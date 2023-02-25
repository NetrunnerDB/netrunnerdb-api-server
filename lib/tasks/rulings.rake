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
