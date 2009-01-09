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
class DumpBaseSchema < ActiveRecord::Migration
  def self.up
    create_table "appels", :force => true do |t|
      t.column "beneficiaire_id", :integer
      t.column "ingenieur_id",    :integer
      t.column "debut",           :datetime
      t.column "fin",             :datetime
      t.column "contract_id",      :integer,  :default => 0, :null => false
      t.column "demande_id",      :integer
    end

    add_index "appels", ["beneficiaire_id"]
    add_index "appels", ["ingenieur_id"]
    add_index "appels", ["contract_id"]

    create_table "arches", :force => true do |t|
      t.column "nom", :string, :default => "", :null => false
    end

    create_table "beneficiaires", :force => true do |t|
      t.column "client_id",            :integer, :default => 0,    :null => false
      t.column "beneficiaire_id",      :integer
      t.column "identifiant_id",       :integer, :default => 0,    :null => false
      t.column "notifier_subalternes", :boolean, :default => true, :null => false
      t.column "notifier",             :boolean, :default => true, :null => false
      t.column "notifier_cc",          :boolean, :default => true, :null => false
    end

    add_index "beneficiaires", ["client_id"]
    add_index "beneficiaires", ["beneficiaire_id"]
    add_index "beneficiaires", ["identifiant_id"]

    create_table "binaires", :force => true do |t|
      t.column "paquet_id",             :integer, :default => 0, :null => false
      t.column "arch_id",               :integer, :default => 0, :null => false
      t.column "nom",                   :string
      t.column "configuration",         :text
      t.column "archive",               :string
      t.column "socle_id",              :integer
      t.column "fichierbinaires_count", :integer
    end

    add_index "binaires", ["paquet_id"]
    add_index "binaires", ["arch_id"]

    create_table "binaires_contributions", :id => false, :force => true do |t|
      t.column "binaire_id",      :integer
      t.column "contribution_id", :integer
    end

    add_index "binaires_contributions", ["binaire_id"]
    add_index "binaires_contributions", ["contribution_id"]

    create_table "binaires_demandes", :id => false, :force => true do |t|
      t.column "binaire_id", :integer
      t.column "demande_id", :integer
    end

    add_index "binaires_demandes", ["binaire_id"]
    add_index "binaires_demandes", ["demande_id"]

    create_table "changelogs", :force => true do |t|
      t.column "paquet_id",         :integer,   :default => 0,  :null => false
      t.column "date_modification", :timestamp,                 :null => false
      t.column "nom_modification",  :string,    :default => "", :null => false
      t.column "text_modification", :text,      :default => "", :null => false
    end

    add_index "changelogs", ["paquet_id"]

    create_table "clients", :force => true do |t|
      t.column "nom",                 :string,  :default => "",    :null => false
      t.column "description",         :text,    :default => "",    :null => true
      t.column "mailingliste",        :string,  :default => "",    :null => false
      t.column "adresse",             :text,    :default => "",    :null => true
      t.column "image_id",            :integer
      t.column "support_id",          :integer
      t.column "code_acces",          :string,  :default => "",    :null => false
      t.column "beneficiaires_count", :integer
      t.column "chrono",              :string
      t.column "inactive",            :boolean, :default => false, :null => false
    end

    add_index "clients", ["image_id"]
    add_index "clients", ["support_id"]

    create_table "clients_socles", :id => false, :force => true do |t|
      t.column "client_id", :integer
      t.column "socle_id",  :integer
    end

    add_index "clients_socles", ["client_id"]
    add_index "clients_socles", ["socle_id"]

    create_table "commentaires", :force => true do |t|
      t.column "demande_id",     :integer,  :default => 0,     :null => false
      t.column "identifiant_id", :integer,  :default => 0,     :null => false
      t.column "piecejointe_id", :integer
      t.column "corps",          :text
      t.column "created_on",     :datetime
      t.column "updated_on",     :datetime
      t.column "prive",          :boolean,  :default => false, :null => false
      t.column "severite_id",    :integer
      t.column "statut_id",      :integer
      t.column "ingenieur_id",   :integer
    end

    add_index "commentaires", ["demande_id"]
    add_index "commentaires", ["piecejointe_id"]
    add_index "commentaires", ["identifiant_id"]
    add_index "commentaires", ["ingenieur_id"]
    add_index "commentaires", ["created_on"]
    add_index "commentaires", ["updated_on"]

    create_table "communautes", :force => true do |t|
      t.column "nom",         :string,   :default => "", :null => false
      t.column "description", :text,     :default => "", :null => false
      t.column "url",         :string,   :default => "", :null => false
      t.column "created_on",  :datetime,                 :null => false
      t.column "updated_on",  :datetime,                 :null => false
    end

    create_table "competences", :force => true do |t|
      t.column "nom", :string, :default => "", :null => false
    end

    create_table "competences_ingenieurs", :id => false, :force => true do |t|
      t.column "ingenieur_id",  :integer, :default => 0, :null => false
      t.column "competence_id", :integer, :default => 0, :null => false
      t.column "niveau",        :integer
    end

    add_index "competences_ingenieurs", ["ingenieur_id"]
    add_index "competences_ingenieurs", ["competence_id"]

    create_table "competences_logiciels", :id => false, :force => true do |t|
      t.column "competence_id", :integer, :default => 0, :null => false
      t.column "logiciel_id",   :integer, :default => 0, :null => false
    end

    add_index "competences_logiciels", ["logiciel_id"]
    add_index "competences_logiciels", ["competence_id"]

    create_table "conteneurs", :force => true do |t|
      t.column "nom", :string, :default => "", :null => false
    end

    create_table "contracts", :force => true do |t|
      t.column "client_id",     :integer,  :default => 0,     :null => false
      t.column "ouverture",     :datetime,                    :null => false
      t.column "cloture",       :datetime,                    :null => false
      t.column "paquets_count", :integer
      t.column "astreinte",     :boolean,  :default => false, :null => false
      t.column "socle",         :boolean,  :default => false, :null => false
      t.column "nom",           :string
      t.column "support",       :boolean,  :default => false
    end

    add_index "contracts", ["client_id"]

    create_table "contracts_engagements", :id => false, :force => true do |t|
      t.column "contract_id",    :integer, :default => 0, :null => false
      t.column "engagement_id", :integer, :default => 0, :null => false
    end

    add_index "contracts_engagements", ["contract_id"]
    add_index "contracts_engagements", ["engagement_id"]

    create_table "contracts_ingenieurs", :id => false, :force => true do |t|
      t.column "contract_id",   :integer, :default => 0, :null => false
      t.column "ingenieur_id", :integer, :default => 0, :null => false
    end

    add_index "contracts_ingenieurs", ["ingenieur_id"]
    add_index "contracts_ingenieurs", ["contract_id"]

    create_table "contributions", :force => true do |t|
      t.column "nom",                       :string,   :default => "", :null => false
      t.column "description",               :text,     :default => "", :null => false
      t.column "patch",                     :string,   :default => "", :null => false
      t.column "created_on",                :datetime,                 :null => false
      t.column "updated_on",                :datetime,                 :null => false
      t.column "id_mantis",                 :integer
      t.column "reverse_le",                :datetime
      t.column "description_fonctionnelle", :text,     :default => "", :null => false
      t.column "etatreversement_id",        :integer,  :default => 0,  :null => false
      t.column "cloture_le",                :datetime
      t.column "logiciel_id",               :integer,  :default => 0,  :null => false
      t.column "ingenieur_id",              :integer,  :default => 0,  :null => false
      t.column "typecontribution_id",       :integer,  :default => 0,  :null => false
      t.column "version",                   :string
      t.column "synthese",                  :text
    end

    add_index "contributions", ["logiciel_id"]
    add_index "contributions", ["ingenieur_id"]

    create_table "contributions_paquets", :id => false, :force => true do |t|
      t.column "contribution_id", :integer
      t.column "paquet_id",       :integer, :default => 0, :null => false
    end

    add_index "contributions_paquets", ["paquet_id"]
    add_index "contributions_paquets", ["contribution_id"]

    create_table "demandes", :force => true do |t|
      t.column "beneficiaire_id",  :integer,  :default => 0,  :null => false
      t.column "ingenieur_id",     :integer
      t.column "resume",           :string,   :default => "", :null => false
      t.column "description",      :text
      t.column "statut_id",        :integer,  :default => 0,  :null => false
      t.column "severite_id",      :integer,  :default => 0,  :null => false
      t.column "logiciel_id",      :integer,  :default => 0
      t.column "created_on",       :datetime
      t.column "updated_on",       :datetime
      t.column "typedemande_id",   :integer,  :default => 0,  :null => false
      t.column "contribution_id",  :integer
      t.column "socle_id",         :integer
      t.column "mail_cc",          :string
      t.column "first_comment_id", :integer
      t.column "contract_id",       :integer,                  :null => false
      t.column "expected_on",      :datetime
      t.column "last_comment_id",  :integer,  :default => 0,  :null => false
      t.column "mantis_id",        :integer
    end

    add_index "demandes", ["contribution_id"]
    add_index "demandes", ["beneficiaire_id"]
    add_index "demandes", ["ingenieur_id"]
    add_index "demandes", ["severite_id"]
    add_index "demandes", ["typedemande_id"]
    add_index "demandes", ["contract_id"]
    add_index "demandes", ["created_on"]
    add_index "demandes", ["updated_on"]

    create_table "demandes_paquets", :id => false, :force => true do |t|
      t.column "paquet_id",  :integer, :default => 0, :null => false
      t.column "demande_id", :integer, :default => 0, :null => false
    end

    add_index "demandes_paquets", ["paquet_id"]
    add_index "demandes_paquets", ["demande_id"]

    create_table "dependances", :force => true do |t|
      t.column "paquet_id", :integer,               :default => 0,  :null => false
      t.column "nom",       :string,                :default => "", :null => false
      t.column "sens",      :string,  :limit => 15, :default => "", :null => false
      t.column "version",   :string,                :default => "", :null => false
    end

    create_table "distributeurs", :force => true do |t|
      t.column "nom", :string, :default => "", :null => false
    end

    create_table "document_versions", :force => true do |t|
      t.column "document_id",     :integer
      t.column "version",         :integer
      t.column "identifiant_id",  :integer,  :default => 0
      t.column "typedocument_id", :integer,  :default => 0
      t.column "client_id",       :integer,  :default => 0
      t.column "titre",           :string,   :default => ""
      t.column "fichier",         :string,   :default => ""
      t.column "description",     :text
      t.column "created_on",      :datetime
      t.column "updated_on",      :datetime
      t.column "date_delivery",   :datetime
    end

    create_table "documents", :force => true do |t|
      t.column "identifiant_id",  :integer,   :default => 0,  :null => false
      t.column "typedocument_id", :integer,   :default => 0,  :null => false
      t.column "client_id",       :integer,   :default => 0,  :null => false
      t.column "titre",           :string,    :default => "", :null => false
      t.column "fichier",         :string,    :default => "", :null => false
      t.column "description",     :text,      :default => "", :null => false
      t.column "created_on",      :timestamp,                 :null => false
      t.column "updated_on",      :timestamp,                 :null => false
      t.column "version",         :integer
      t.column "date_delivery",   :datetime
    end

    add_index "documents", ["identifiant_id"]
    add_index "documents", ["typedocument_id"]
    add_index "documents", ["client_id"]

    create_table "engagements", :force => true do |t|
      t.column "severite_id",    :integer, :default => 0,   :null => false
      t.column "contournement",  :float,   :default => 0.0
      t.column "correction",     :float,   :default => 0.0
      t.column "typedemande_id", :integer, :default => 0,   :null => false
    end

    add_index "engagements", ["severite_id", "typedemande_id"]

    create_table "etapes", :force => true do |t|
      t.column "nom",         :string, :default => "", :null => false
      t.column "description", :text
    end

    create_table "etatreversements", :force => true do |t|
      t.column "nom",         :string, :default => "", :null => false
      t.column "description", :text,   :default => "", :null => false
    end

    create_table "fichierbinaires", :force => true do |t|
      t.column "binaire_id", :integer
      t.column "chemin",     :string
      t.column "taille",     :integer
    end

    add_index "fichierbinaires", ["binaire_id"]

    create_table "fichiers", :force => true do |t|
      t.column "paquet_id", :integer, :default => 0,  :null => false
      t.column "chemin",    :string,  :default => ""
      t.column "taille",    :integer, :default => 0,  :null => false
    end

    add_index "fichiers", ["paquet_id"]

    create_table "groupes", :force => true do |t|
      t.column "nom", :string, :limit => 80
    end

    create_table "identifiants", :force => true do |t|
      t.column "login",        :string,  :limit => 20, :default => "",    :null => false
      t.column "password",     :string,  :limit => 40, :default => "",    :null => false
      t.column "titre",        :string,                :default => "",    :null => false
      t.column "nom",          :string,                :default => "",    :null => false
      t.column "email",        :string,                :default => "",    :null => false
      t.column "telephone",    :string,                :default => "",    :null => false
      t.column "image_id",     :integer
      t.column "informations", :text,                  :default => "",    :null => true
      t.column "client",       :boolean,               :default => false, :null => false
      t.column "inactive",     :boolean,               :default => false, :null => false
      t.column "role_id",      :integer,               :default => 0,     :null => false
    end

    add_index "identifiants", ["image_id"]
    add_index "identifiants", ["email"]

    create_table "images", :force => true do |t|
      t.column "image",       :string
      t.column "description", :string
    end

    create_table "ingenieurs", :force => true do |t|
      t.column "identifiant_id", :integer, :default => 0,     :null => false
      t.column "chef_de_projet", :boolean, :default => false, :null => false
      t.column "expert_ossa",    :boolean, :default => false, :null => false
      t.column "image_id",       :integer
    end

    add_index "ingenieurs", ["identifiant_id"]

    create_table "jourferies", :force => true do |t|
      t.column "jour", :timestamp, :null => false
    end

    create_table "licenses", :force => true do |t|
      t.column "nom",          :string,  :limit => 63, :default => "", :null => false
      t.column "url",          :string,                :default => "", :null => false
      t.column "certifie_osi", :boolean
    end

    create_table "logiciels", :force => true do |t|
      t.column "nom",         :string,  :default => "", :null => false
      t.column "referent",    :string
      t.column "resume",      :string,  :default => "", :null => false
      t.column "description", :text
      t.column "license_id",  :integer, :default => 0,  :null => false
      t.column "groupe_id",   :integer
      t.column "image_id",    :integer
    end

    add_index "logiciels", ["referent"]
    add_index "logiciels", ["license_id"]
    add_index "logiciels", ["image_id"]

    create_table "machines", :force => true do |t|
      t.column "socle_id",    :integer, :default => 0, :null => false
      t.column "acces",       :string
      t.column "virtuelle",   :boolean
      t.column "hote_id",     :integer
      t.column "description", :text
    end

    create_table "mainteneurs", :force => true do |t|
      t.column "nom", :string, :default => "", :null => false
    end

    create_table "news", :force => true do |t|
      t.column "subject",      :string,   :default => "", :null => false
      t.column "source",       :string,   :default => "", :null => false
      t.column "body",         :text
      t.column "created_on",   :datetime
      t.column "updated_on",   :datetime
      t.column "ingenieur_id", :integer,                  :null => false
      t.column "client_id",    :integer
      t.column "logiciel_id",  :integer,                  :null => false
    end

    add_index "news", ["ingenieur_id"]
    add_index "news", ["logiciel_id"]
    add_index "news", ["subject"]

    create_table "paquets", :force => true do |t|
      t.column "logiciel_id",      :integer,               :default => 0,    :null => false
      t.column "nom",              :string,  :limit => 60, :default => "",   :null => false
      t.column "version",          :string,  :limit => 60, :default => "",   :null => false
      t.column "release",          :string,  :limit => 60, :default => "",   :null => false
      t.column "conteneur_id",     :integer,               :default => 0,    :null => false
      t.column "paquet_id",        :integer,               :default => 0,    :null => false
      t.column "distributeur_id",  :integer,               :default => 0,    :null => false
      t.column "mainteneur_id",    :integer,               :default => 0,    :null => false
      t.column "contract_id",       :integer,               :default => 0,    :null => false
      t.column "taille",           :integer,               :default => 0,    :null => false
      t.column "configuration",    :text,                  :default => "",   :null => false
      t.column "fichiers_count",   :integer
      t.column "changelogs_count", :integer
      t.column "active",           :boolean,               :default => true
    end

    add_index "paquets", ["nom", "version", "release"]
    add_index "paquets", ["paquet_id"]
    add_index "paquets", ["logiciel_id"]
    add_index "paquets", ["conteneur_id"]
    add_index "paquets", ["distributeur_id"]
    add_index "paquets", ["mainteneur_id"]
    add_index "paquets", ["contract_id"]

    create_table "permissions", :force => true do |t|
      t.column "name", :string,               :default => "", :null => false
      t.column "info", :string, :limit => 80
    end

    create_table "permissions_roles", :id => false, :force => true do |t|
      t.column "role_id",       :integer, :limit => 10, :default => 0, :null => false
      t.column "permission_id", :integer, :limit => 10, :default => 0, :null => false
    end

    add_index "permissions_roles", ["permission_id"]
    add_index "permissions_roles", ["role_id"]

    create_table "appels", :force => true do |t|
      t.column "beneficiaire_id", :integer
      t.column "ingenieur_id",    :integer
      t.column "debut",           :datetime
      t.column "fin",             :datetime
      t.column "contract_id",      :integer,  :default => 0, :null => false
      t.column "demande_id",      :integer
    end

    add_index "appels", ["beneficiaire_id"]
    add_index "appels", ["ingenieur_id"]
    add_index "appels", ["contract_id"]

    create_table "piecejointes", :force => true do |t|
      t.column "file", :string, :default => "", :null => false
    end

    create_table "preferences", :force => true do |t|
      t.column "identifiant_id", :integer,                    :null => false
      t.column "mail_text",      :boolean, :default => false
      t.column "all_mail",       :boolean, :default => true
      t.column "digest_daily",   :boolean, :default => false
      t.column "digest_weekly",  :boolean, :default => false
    end

    add_index "preferences", ["identifiant_id"]

    create_table "roles", :force => true do |t|
      t.column "nom",  :string, :limit => 40
      t.column "info", :string, :limit => 80
    end

    create_table "sessions", :force => true do |t|
      t.column "session_id", :string
      t.column "data",       :text
      t.column "created_at", :datetime
      t.column "updated_at", :datetime
    end

    add_index "sessions", ["session_id"]

    create_table "severites", :force => true do |t|
      t.column "nom", :string, :default => "", :null => false
    end

    create_table "socles", :force => true do |t|
      t.column "nom",            :string,  :default => "", :null => false
      t.column "binaires_count", :integer
    end

    create_table "statuts", :force => true do |t|
      t.column "nom",         :string, :default => "", :null => false
      t.column "description", :text,   :default => "", :null => false
    end

    create_table "supports", :force => true do |t|
      t.column "nom",                  :string,  :default => "",    :null => false
      t.column "maintenance",          :boolean, :default => false
      t.column "assistance_tel",       :boolean, :default => false
      t.column "veille_technologique", :boolean, :default => false
      t.column "ouverture",            :integer, :default => 0,     :null => false
      t.column "fermeture",            :integer, :default => 0,     :null => false
      t.column "newsletter",           :boolean
      t.column "duree_intervention",   :integer
    end

    create_table "typecontributions", :force => true do |t|
      t.column "nom",         :string, :default => "", :null => false
      t.column "description", :text,   :default => "", :null => false
    end

    create_table "typedemandes", :force => true do |t|
      t.column "nom", :string, :default => "", :null => false
    end

    create_table "typedocuments", :force => true do |t|
      t.column "nom",         :string, :default => "", :null => false
      t.column "description", :text,   :default => "", :null => false
    end

    create_table "typeurls", :force => true do |t|
      t.column "nom", :string, :default => "", :null => false
    end

    create_table "urllogiciels", :force => true do |t|
      t.column "logiciel_id", :integer, :default => 0,  :null => false
      t.column "typeurl_id",  :integer, :default => 0,  :null => false
      t.column "valeur",      :string,  :default => "", :null => false
    end

    add_index "urllogiciels", ["valeur"]
    add_index "urllogiciels", ["logiciel_id"]

    create_table "urlreversements", :force => true do |t|
      t.column "contribution_id", :integer
      t.column "valeur",          :string,  :default => "", :null => false
    end
  end

  def self.down
    drop_table "appels"
    drop_table "arches"
    drop_table "beneficiaires"
    drop_table "binaires"
    drop_table "binaires_contributions"
    drop_table "binaires_demandes"
    drop_table "changelogs"
    drop_table "clients"
    drop_table "clients_socles"
    drop_table "commentaires"
    drop_table "communautes"
    drop_table "competences"
    drop_table "competences_ingenieurs"
    drop_table "competences_logiciels"
    drop_table "conteneurs"
    drop_table "contracts"
    drop_table "contracts_engagements"
    drop_table "contracts_ingenieurs"
    drop_table "contributions"
    drop_table "contributions_paquets"
    drop_table "demandes"
    drop_table "demandes_paquets"
    drop_table "dependances"
    drop_table "distributeurs"
    drop_table "document_versions"
    drop_table "documents"
    drop_table "engagements"
    drop_table "etapes"
    drop_table "etatreversements"
    drop_table "fichierbinaires"
    drop_table "fichiers"
    drop_table "groupes"
    drop_table "identifiants"
    drop_table "images"
    drop_table "ingenieurs"
    drop_table "jourferies"
    drop_table "licenses"
    drop_table "logiciels"
    drop_table "machines"
    drop_table "mainteneurs"
    drop_table "news"
    drop_table "paquets"
    drop_table "permissions"
    drop_table "permissions_roles"
    drop_table "appels"
    drop_table "piecejointes"
    drop_table "preferences"
    drop_table "roles"
    drop_table "sessions"
    drop_table "severites"
    drop_table "socles"
    drop_table "statuts"
    drop_table "supports"
    drop_table "typecontributions"
    drop_table "typedemandes"
    drop_table "typedocuments"
    drop_table "typeurls"
    drop_table "urllogiciels"
    drop_table "urlreversements"
  end
end
