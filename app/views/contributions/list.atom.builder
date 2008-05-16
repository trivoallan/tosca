atom_feed do |feed|
  feed.title(_('Contributions of 08000linux.com'))
  feed.link("http://" + request.host_with_port + request.request_uri)
  feed.updated(@contributions.first.updated_on)
  for contribution in @contributions
    feed.entry(contribution) do |entry|
      entry.updated contribution.created_on.rfc822
      entry.title("[#{contribution.logiciel.name}] #{contribution.synthese}")
      entry.content(contribution.description_fonctionnelle, :type => 'html')
      entry.author do |author|
        author.name(contribution.ingenieur.name)
      end
    end
  end
end

