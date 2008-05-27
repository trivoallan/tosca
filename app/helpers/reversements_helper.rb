module ReversementsHelper
  def link_to_reversement(reversement)
    if reversement.interaction
      display = reversement.interaction.resume
    else
      display = "le reversement est orphelin : il n'est pas lié à une interaction"
    end
    link_to display, reversement_path(reversement.id)
  end

end
