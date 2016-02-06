import sys
from PyQt4.QtGui import *
from PyQt4.QtCore import *
from PyQt4.QtWebKit import *
from webscraping import xpath

class Render(QWebPage):
    def __init__(self, url):
        self.app = QApplication(sys.argv)
        QWebPage.__init__(self)
        self.loadFinished.connect(self._loadFinished)
        self.mainFrame().load(QUrl(url))
        self.app.exec_()
    
    def _loadFinished(self, result):
        self.frame = self.mainFrame()
        self.app.quit()

search_term = sys.argv[1]
yr = int(sys.argv[2])

url = 'http://query.nytimes.com/search/sitesearch/?action=click&contentCollection&region=TopBar&WT.nav=searchWidget&module=SearchSubmit&pgtype=Homepage#/'+search_term+'/from'+str(yr)+'0101to'+str(yr+1)+'0101/'

r = Render(url)
result = str(r.frame.toHtml().toAscii())
results = xpath.get(result,'//div[@id="totalResultsCount"]/p/text()')

with open('results.out','a') as f:
    f.write("{:}\t{:}\t{:}\n".format(search_term, yr, results.split()[3]))
    
# from lxml import html 2/1

# def scrape(url,html_):
#     formatted_result = str(html_.toAscii())
#     tree = html.fromstring(formatted_result)
#     results = tree.xpath('//div[@id="totalResultsCount"]/p/text()')
#     print results
# 2/1

# #QString should be converted to string before processed by lxml
# formatted_result = str(result.toAscii())

# #Next build lxml tree from formatted_result
# tree = html.fromstring(formatted_result)

# #Now using correct Xpath we are fetching URL of archives
# results = tree.xpath('//div[@id="totalResultsCount"]/p/text()')
# 2/1