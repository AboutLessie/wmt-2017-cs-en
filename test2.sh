echo '----------START----------'

tokenize () {
  '/home/alicja/mosesdecoder/scripts/tokenizer/tokenizer.perl' -l $2 -threads 4 -no-escape < $1 > $3
}

lowercase () {
  '/home/alicja/mosesdecoder/scripts/tokenizer/lowercase.perl' < $1 > $1'.lowercased'
}

preprocess(){
  unxz --keep '/home/alicja/wmtTEST/train/news-commentary-v12.tsv.xz'

  cut -f 1 '/home/alicja/wmtTEST/train/news-commentary-v12.tsv' > '/home/alicja/wmtTEST/news.cs'
  cut -f 2 '/home/alicja/wmtTEST/train/news-commentary-v12.tsv' > '/home/alicja/wmtTEST/news.en'

  /home/alicja/mosesdecoder/scripts/training/clean-corpus-n.perl news cs en clean 1 50

  tokenize 'clean.cs' cs 'news.cs.t'
  tokenize 'clean.en' en 'news.en.t'
  tokenize '/home/alicja/wmtTEST/test-A/in.tsv' cs 'test.in.t'

  lowercase 'news.cs.t'
  lowercase 'news.en.t'
  lowercase 'test.in.t'

  echo 'Preprocess finished'
}

createModel(){
  mv 'news.cs.t.lowercased' 'news.cs'
  mv 'news.en.t.lowercased' 'news.en'
  /home/alicja/mosesdecoder/bin/lmplz -o 3 < '/home/alicja/wmtTEST/news.en' > 'language_model.arpa' --discount_fallback
}

train(){
  /home/alicja/mosesdecoder/scripts/training/train-model.perl -root-dir . -external-bin-dir '/home/alicja/mosesdecoder/tools/' --lm 0:3:'/home/alicja/wmtTEST/language_model.arpa' --f cs --e en --corpus news
}

translate(){
  /home/alicja/mosesdecoder/bin/moses -f '/home/alicja/wmtTEST/model/moses.ini' < '/home/alicja/wmtTEST/test.in.t.lowercased' > '/home/alicja/wmtTEST/test-A/out'
}


preprocess
createModel
train
translate
