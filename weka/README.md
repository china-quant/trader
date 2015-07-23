### how to build a model
1. pull training data and classify it with implicit knowledge of the future
2. open weka, load training data
3. select model type
4. train model
5. right click in the *results list* on the model, and *save model*

### how to test a model
1. create an `.arff` file containing all test days
   `./uptrend_n_days_before_miner.rb [ticker] [start date yyyy-mm-dd] [n days before] [options [-e [end-date yyyy-mm-dd]] ...] > file.arff`
   `./uptrend_n_days_before_miner.rb dia 2013-07-22 4 > dia_2013-07-22_to_2015-07-22_4d_hlc_0-2.arff`
2. open weka, load the model, run on the test data to produce predictions.
3. save predictions to `/weka/` under some unique .txt filename
   `pbpaste > pred.txt`
4. run model tester, pointed at said predictions file, with same start/end dates as the `.arrf`
   `./model_tester.rb [ticker] [start date yyyy-mm-dd] [predictions.txt] -e [optional end-date]`
   `./model_tester.rb dia 2013-07-22 pred.txt`
