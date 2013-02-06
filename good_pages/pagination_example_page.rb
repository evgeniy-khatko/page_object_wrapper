PageObjectWrapper.define_page(:google_pagination) do
  locator 'https://www.google.ru/#hl=ru&newwindow=1&tbo=d&output=search&sclient=psy-ab&q=123&oq=123&gs_l=hp.3..35i39j0l3.1315.1644.0.1789.3.3.0.0.0.0.101.214.2j1.3.0...0.0...1c.1.2.hp.RHZTJZtdIWY&pbx=1&bav=on.2,or.r_gc.r_pw.r_cp.r_qf.&bvm=bv.41867550,d.bGE&fp=bd383a4eab7647dd&biw=1920&bih=965'
  uniq_input :id => 'gbqfq'

  pagination :pagination do
    locator "table(:id => 'nav').tr.td.a(:text => '2')", '2'
  end
end

PageObjectWrapper.define_page :yandex_pagination do
  locator 'http://yandex.ru/yandsearch?text=123&lr=213&msid=20941.6968.1359721756.81263'
  uniq_input :class => 'b-form-input__input'  

  pagination :pagination do
    locator "link(:class => 'b-pager__page b-link b-link_ajax_yes', :text => '2')", '2'
  end
end

PageObjectWrapper.define_page(:google_invalid_pagination) do
  locator 'https://www.google.ru/#hl=ru&newwindow=1&tbo=d&output=search&sclient=psy-ab&q=123&oq=123&gs_l=hp.3..35i39j0l3.1315.1644.0.1789.3.3.0.0.0.0.101.214.2j1.3.0...0.0...1c.1.2.hp.RHZTJZtdIWY&pbx=1&bav=on.2,or.r_gc.r_pw.r_cp.r_qf.&bvm=bv.41867550,d.bGE&fp=bd383a4eab7647dd&biw=1920&bih=965'
  uniq_input :id => 'gbqfq'

  pagination :invalid_pagination do
    locator "table(:id => 'nav').tr.td.a(:text => '1000')", '1000'
  end
end
