#
# Copyright (c) 2006-2009 Linagora
#
# This file is part of Tosca
#
# Tosca is free software, you can redistribute it and/or modify
# it under the terms of the GNU General Public License as
# published by the Free Software Foundation; either version 2 of
# the License, or (at your option) any later version.
#
# Tosca is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU Lesser General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.
#
class LoadRequestStatus < ActiveRecord::Migration
  class Statut < ActiveRecord::Base; end

  def self.up
    # Do not erase existing status
    return unless Statut.count == 0

    # Allowed status for a request
    [ [ 'Submitted', "Votre demande vient d'être déclarée dans notre outil.<br /> Nous vous rappelons dans l'heure pour réunir toutes les informations nécessaires et vous informer de la prise en compte effective de votre demande." ],
      [ 'Accepted', "Votre demande est prise en compte par nos experts, qui font le nécessaire pour qualifier votre demande.<br /> Pour ce faire, ils vont périodiquement vous demander des informations, ce qui suspendra le décompte du temps garanti. <br /> Une fois cette analyse complète, votre demande prendra le statut \"Analysée\". Si nous nous apercevons que votre demande sort du périmètre de votre contract, elle sera annulée, avec votre accord." ],
      [ 'Suspended', "Nous attendons des informations pour pouvoir continuer de travailler sur votre demande.<br /> Ces informations peuvent être des fichiers de configuration, des numéros de version ou le résultat de commandes d'analyse.<br /> Si votre réponse est positive à une demande de validation, elle prendra alors le statut \"Contournée\" ou le statut \"Corrigée\"." ],
      [ 'Analysed', "Nous avons tous les éléments nécessaire pour règler votre anomalie.<br /> A ce stade, vous ne devriez plus être sollicité pour des informations complémentaires. <br /> Vous obtiendrez dès que possible des propositions de solution de contournement et de correction. <br /> Votre demande sera alors \"suspendue\", le temps pour vous de confirmer ou d'infirmer que le contournement ou la correction proposés vous conviennent. <br /> La demande prendra éventuellement de nouveau le statut \"Prise en compte\" s'il s'avère que nous sommes partis sur une mauvaise piste." ],
      [ 'Bypassed', "Vous avez accepté une de nos solutions de contournement. <br /> Nous continuons à travailler et la demande repassera en \"Suspendue\" dès que nous vous proposons une solution de correction <br />" ],
      [ 'Fixed', "Vous avez accepté une de nos solutions de correction. <br /> Nous soumettons maintenant notre correctif à la communauté, pour pouvoir clôturer la demande." ],
      [ 'Closed', "L'anomalie est considérée comme définitivement close, le correctif ayant été soumis à la communauté. <br />" ],
      [ 'Cancelled', "D'une manière générale, une demande est annulée quand son traitement n'est pas du ressort de notre unité. <br>Les cas possibles d'annulation sont : <br></p><ul><li>problème dont la cause matérielle, </li><li>problème dont la cause est un logiciel ou un ensemble de logiciels non assurés, </li><li>demande nécessitant une évolution du logiciel assuré </li><li>cas d'exclusion prévus contractuellement.</li></ul>" ] ].each { |s|
      Statut.create(:nom => s.first, :description => s.last)
    }
  end

  def self.down
    Statut.destroy_all
  end
end
