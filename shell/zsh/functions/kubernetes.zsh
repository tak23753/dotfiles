# skaffold
skaffold() {
  # 実行しようとしているサブコマンドを取得
  local sub_cmd="$1"

  # dev, run, debug など、デプロイを伴う操作のみチェック対象にする
  if [[ "$sub_cmd" == "dev" || "$sub_cmd" == "run" || "$sub_cmd" == "debug" ]]; then

    # 現在のコンテキストの API サーバーのURLを取得
    local cluster_url=$(kubectl config view --minify -o jsonpath='{.clusters[0].cluster.server}')
    local current_ctx=$(kubectl config current-context)

    # 「localhost」や「127.0.0.1」を含まない場合は警告して中断
    # ※ minikubeやDocker Desktop, kindなどは通常ここがローカルIPになります
    if [[ ! "$cluster_url" =~ "localhost" && ! "$cluster_url" =~ "127.0.0.1" && ! "$cluster_url" =~ "::1" ]]; then
      echo "現在のコンテキスト '$current_ctx' はローカルクラスタではないようです。"
      echo "API Server: $cluster_url"
      echo "本番・共有環境への誤爆防止のため、実行を中止しました。"
      return 1
    fi
  fi

  # 安全が確認されたか、チェック対象外のコマンドなら本物の skaffold を実行
  command skaffold "$@"
}
