@isTest
public class TestSurveySitesUtil {
    
	@isTest static void testSurveySiteInfo() {
		SurveySitesUtil.SurveySiteInfo info = new SurveySitesUtil.SurveySiteInfo('one', 'two', 'three');
		System.assertEquals(info.name, 'one');
		System.assertEquals(info.prefix, 'two');
		System.assertEquals(info.subdomain, 'three');
	}
	
	@isTest static void testHasSites() {
		SurveySitesUtil util = new SurveySitesUtil();
		
		if (Schema.getGlobalDescribe().keySet().contains('site')) {
			System.assert(util.hasSites());
		} else {
			System.assert(!util.hasSites());
		}
	}
	
	@isTest static void testGetInfo() {
		SurveySitesUtil util = new SurveySitesUtil();
		System.assert(util.getSiteList() != null);
		if (util.hasSites()) {
			if (util.getSiteList().size() > 0) {
				SurveySitesUtil.SurveySiteInfo current = util.getSiteList()[0];
				System.assert(current != null);
			}
		}
	}
}