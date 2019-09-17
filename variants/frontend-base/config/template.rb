gsub_file "config/webpacker.yml", 
          "source_path: app/javascript", 
          "source_path: app/frontend/javascript", 
          force: true
gsub_file "config/webpacker.yml", 
          "source_entry_path: packs",
          "source_entry_path: ../packs",
          force: true