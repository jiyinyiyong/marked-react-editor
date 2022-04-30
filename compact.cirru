
{} (:package |app)
  :configs $ {} (:init-fn |app.main/main!) (:reload-fn |app.main/reload!) (:version |0.0.1)
    :modules $ [] |respo.calcit/ |lilac/ |memof/ |respo-ui.calcit/ |respo-markdown.calcit/ |reel.calcit/ |respo-feather.calcit/
  :entries $ {}
  :files $ {}
    |app.comp.container $ {}
      :defs $ {}
        |comp-container $ quote
          defcomp comp-container (reel)
            let
                store $ :store reel
                states $ :states store
                preview? $ :preview? store
              div
                {} $ :class-name css-container
                div
                  {} (:id "\"article")
                    :style $ merge ui/flex
                      {}
                        :padding $ if preview? "|40px 240px 240px 240px" "|16px 16px 240px 16px"
                        :flex-shrink 0
                        :overflow :auto
                  comp-md-block (:content store)
                    {} (:css |)
                      :style $ {} (:font-size 16)
                      :highlight $ fn (code lang)
                        if (contains? supported-langs lang)
                          .-value $ hljs/highlight (get supported-langs lang) code
                          escape-html code
                if (not preview?)
                  textarea $ {} (:class-name css-textbox)
                    :value $ :content store
                    :placeholder "|Markdown syntax supported~"
                    :on-input $ fn (e d!)
                      d! :content $ :value e
                    :autofocus true
                div ({})
                  div
                    {} $ :style
                      {} (:position :fixed) (:top 0) (:right 0)
                    div
                      {} (:class-name css-icon)
                        :on-click $ fn (e d!) (d! :toggle nil)
                      comp-i :film 14 $ hsl 200 80 80
                    div
                      {} (:class-name css-icon)
                        :on-click $ fn (e d!) (read-from-dom!)
                      comp-i :volume-2 14 $ hsl 200 80 80
                  div
                    {} $ :style
                      merge ui/center $ {} (:width 40) (:height 40) (:position :fixed) (:right 0) (:bottom 0)
                    a
                      {} (:href "\"https://github.com/Memkits/markdown-editor") (:target "\"_blank")
                      comp-i :github 14 $ hsl 200 80 80
                comp-reel (>> states :reel) reel $ {}
        |css-container $ quote
          defstyle css-container $ {}
            "\"$0" $ merge ui/global ui/row ui/fullscreen
              {} $ :overflow :hidden
        |css-icon $ quote
          defstyle css-icon $ {}
            "\"$0" $ merge ui/center
              {} (:width 40) (:height 40) (:cursor :pointer)
        |css-textbox $ quote
          defstyle css-textbox $ {}
            "\"$0" $ merge ui/textarea ui/flex
              {} (:resize :none) (:flex-shrink 0) (:font-family ui/font-code) (:padding-bottom 240) (:padding 16) (:border-width "\"0 0 0 1px")
                :border-color $ hsl 0 0 95
                :border-style :solid
                :background-color $ hsl 0 0 98
        |read-from-dom! $ quote
          defn read-from-dom! () $ let
              el $ .-firstChild (js/document.getElementById "\"article")
              text-array js/[]
            -> el .-children (js/Array.from)
              .!forEach $ fn (child & _xs)
                if
                  not= "\"PRE" $ .-tagName child
                  .!push text-array $ .-innerText child
            if-let
              key $ get-env "\"azure-key"
              speechOne
                .join-str (to-calcit-data text-array) &newline
                , key "\"en-US"
                  fn $
                  fn $
              let
                  msg $ new js/SpeechSynthesisUtterance
                -> msg .-text $ set!
                  .join-str (to-calcit-data text-array) &newline
                js/speechSynthesis.speak msg
        |supported-langs $ quote
          def supported-langs $ {} ("\"clojure" "\"clojure") ("\"clj" "\"clojure") ("\"bash" "\"bash") ("\"js" "\"javascript") ("\"javascript" "\"javascript") ("\"html" "\"xml") ("\"xml" "\"xml") ("\"css" "\"css") ("\"coffeescript" "\"coffeescript") ("\"coffee" "\"coffeescript") ("\"ts" "\"typescript") ("\"typescript" "\"typescript")
      :ns $ quote
        ns app.comp.container $ :require
          [] respo-ui.core :refer $ [] hsl
          [] respo-ui.core :as ui
          [] respo.core :refer $ [] defcomp >> <> div button textarea span a
          [] respo.comp.space :refer $ [] =<
          [] reel.comp.reel :refer $ [] comp-reel
          [] respo-md.comp.md :refer $ [] comp-md comp-md-block
          [] "\"highlight.js" :as hljs
          [] "\"escape-html" :default escape-html
          [] feather.core :refer $ [] comp-i
          respo.css :refer $ defstyle
          "\"@memkits/azure-speech-util" :refer $ speechOne
    |app.config $ {}
      :defs $ {}
        |dev? $ quote
          def dev? $ = "\"dev" (get-env "\"mode" "\"release")
        |site $ quote
          def site $ {} (:dev-ui "\"http://localhost:8100/main-fonts.css") (:release-ui "\"http://cdn.tiye.me/favored-fonts/main-fonts.css") (:cdn-url "\"http://cdn.tiye.me/markdown-editor/") (:title "\"Markdown Editor") (:icon "\"http://cdn.tiye.me/logo/markdown-editor.png") (:storage-key "\"markdown-editor")
      :ns $ quote (ns app.config)
    |app.main $ {}
      :defs $ {}
        |*reel $ quote
          defatom *reel $ -> reel-schema/reel (assoc :base schema/store) (assoc :store schema/store)
        |dispatch! $ quote
          defn dispatch! (op op-data)
            when config/dev? $ println "\"Dispatch:" op
            reset! *reel $ reel-updater updater @*reel op op-data
        |main! $ quote
          defn main! ()
            println "\"Running mode:" $ if config/dev? "\"dev" "\"release"
            if config/dev? $ load-console-formatter!
            .!registerLanguage hljs |clojure clojure-lang
            .!registerLanguage hljs |bash bash-lang
            .!registerLanguage hljs |coffeescript coffeescript-lang
            .!registerLanguage hljs |javascript javascript-lang
            .!registerLanguage hljs |css css-lang
            .!registerLanguage hljs |xml xml-lang
            .!registerLanguage hljs |typescript typescript-lang
            render-app!
            add-watch *reel :changes $ fn (r p) (render-app!)
            listen-devtools! |a dispatch!
            js/window.addEventListener "\"beforeunload" persist-storage!
            js/window.addEventListener "\"keydown" on-window-keydown
            flipped js/setInterval 60000 persist-storage!
            let
                raw $ js/localStorage.getItem (:storage-key config/site)
              if (some? raw)
                do $ dispatch! :hydrate-storage (parse-cirru-edn raw)
            println "|App started."
        |mount-target $ quote
          def mount-target $ .querySelector js/document |.app
        |on-window-keydown $ quote
          defn on-window-keydown (event)
            when
              and
                = "\"e" $ .-key event
                .-metaKey event
              dispatch! :toggle nil
        |persist-storage! $ quote
          defn persist-storage! (? e)
            js/localStorage.setItem (:storage-key config/site)
              format-cirru-edn $ :store @*reel
        |reload! $ quote
          defn reload! () $ if (nil? build-errors)
            do (remove-watch *reel :changes) (clear-cache!)
              add-watch *reel :changes $ fn (reel prev) (render-app!)
              reset! *reel $ refresh-reel @*reel schema/store updater
              hud! "\"ok~" "\"Ok"
            hud! "\"error" build-errors
        |render-app! $ quote
          defn render-app! () $ render! mount-target (comp-container @*reel) dispatch!
      :ns $ quote
        ns app.main $ :require
          [] respo.core :refer $ [] render! clear-cache! realize-ssr!
          [] app.comp.container :refer $ [] comp-container
          [] app.updater :refer $ [] updater
          [] app.schema :as schema
          [] reel.util :refer $ [] listen-devtools!
          [] reel.core :refer $ [] reel-updater refresh-reel
          [] reel.schema :as reel-schema
          [] cljs.reader :refer $ [] read-string
          [] app.config :as config
          [] "\"highlight.js" :default hljs
          [] "\"highlight.js/lib/languages/clojure" :default clojure-lang
          [] "\"highlight.js/lib/languages/coffeescript" :default coffeescript-lang
          [] "\"highlight.js/lib/languages/javascript" :default javascript-lang
          [] "\"highlight.js/lib/languages/css" :default css-lang
          [] "\"highlight.js/lib/languages/xml" :default xml-lang
          [] "\"highlight.js/lib/languages/typescript" :default typescript-lang
          [] "\"highlight.js/lib/languages/bash" :default bash-lang
          "\"./calcit.build-errors" :default build-errors
          "\"bottom-tip" :default hud!
    |app.schema $ {}
      :defs $ {}
        |store $ quote
          def store $ {}
            :states $ {}
            :content |
            :preview? false
      :ns $ quote (ns app.schema)
    |app.updater $ {}
      :defs $ {}
        |updater $ quote
          defn updater (store op op-data op-id op-time)
            case-default op
              do (println "\"Unknown op:" op) store
              :states $ update-states store op-data
              :content $ assoc store :content op-data
              :hydrate-storage op-data
              :toggle $ update store :preview? not
      :ns $ quote
        ns app.updater $ :require
          [] respo.cursor :refer $ [] update-states
