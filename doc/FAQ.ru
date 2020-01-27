

                    Configuration mini-faq

Создатель Andrey Slusar 2:467/126, anray@users.sourceforge.net

Самую свежую версию этого документа можно получить написав нетмейлом письмо:
===
To: FAQServer 2:467/126
Subject: FIDOGATE
===
Если вы хотите внести изменения или дополнения в данный документ желательно
пишите по фидошному адресу.

Также ищутся добровольцы для дополнения и перевода всей или части документации
по fidogate на английский язык.

=============================================================================
  
  Q1:У меня inn не запускается. Пишет, что нет history-файла, хотя такой файл
     на самом деле существует.
   
  A1:Необходимо создать корректный history inn'a:

    От root ввести:
    ===
    su news
    /usr/local/news/bin/makehistory -b -f history -O -l 30000 -I
    /usr/local/news/bin/makedbz -f history -i -o -s 30000
    exit
    /etc/init.d/innd start
    ===
    Все.
  
-----------------------------------------------------------------------------

  Q2:У меня постоянные проблемы с электроэнергией, а UPS нет. В результате
     часто падает inn или не хотят обрабатываться ньюсовые батчи - все летят
     в bad.
    
  A2:Для повышения надежности работы ньюссервера можно вместо storage метода
     tradspool поставить timehash. Для этого достаточно просто прописать в
     storage.conf:
  
  === storage.conf ===
  method timehash {
  newsgroups: *
  class: 0
                  }
  ===		
    
     Как временный метод - можно исправить active-файл и overview таким
     скриптом:
  
  === inn-recover.sh ===
  #!/bin/sh
  /usr/local/etc/rc.d/innd.sh stop
  su news -c "/usr/local/news/bin/makehistory -b -f history -O -l 30000 -I"
  /usr/local/etc/rc.d/innd.sh start
  for act in `cat /usr/local/news/db/active | awk '{print $1}'`
  do
   su news -c "/usr/local/news/bin/ctlinnd renumber $act"
  done
  ===
    Пути к соответствующим файлам подправить.
  Если все-же хочется пользоваться storage-методом tradspool, то рекомендую
  апгрейдить inn до версии >= 2.4.0 и уменьшить значение icdsynccount в inn.conf
  до 1.
  На вопрос "почему так?" может ответить внимантельное прочтение файла NEWS в
  комплекте с inn >= 2.4.0

-----------------------------------------------------------------------------
  
  Q3:Использую inn в качестве ньюссервера. Почему send-fidogate не гейтует в
    pkt исходящие мессаги, а в log-news сыпятся следующие ошибки:
    
    === log-news ===
    Aug 21 00:04:51 rfc2ftn WARNING: can't open /usr/local/news/spool/articles/ \
    @050000000017000017AB0000000000000000@ (errno=2: No such file or directory)
    ===

  A3:Дело в том, что в последних версиях INN используется storage API и для
    правильной работы fidogate нужно поправить send-fidogate:

    Ищем в send-fidogate строку: 
    
     time $RFC2FTN -f $BATCHFILE -m 500

    И меняем ее на такую(все в одну строчку):

     time $PATHBIN/batcher -N $QUEUEJOBS -b500000 -p"$RFC2FTN -b -n" \
     $SITE $BATCHFILE

    Также рекомендуется man batcher.

-----------------------------------------------------------------------------

  Q4:Все вроде настроил правильно, но при запуске runinc почему-то ничего не
     делает - тоссинг не работает. В логах все пусто. Что делать?
    
  A4:Убедиться, что локдир фидогейта существует и что runinc-у хватает прав
     писать в локдир.

-----------------------------------------------------------------------------
    
  Q5:Поставил leafnode 1.x и leafnode-util от Elohin Igor, создаю группы 
     leafnode-group. groupinfo меняется, но leafnode не видит созданных
     групп.
    
  A5:leafnode-group работает только с leafnode 2.x не "плюс". С остальными
     версиями leafnode он работать не будет.

-----------------------------------------------------------------------------
    
  Q6:Поставил leafnode, прописал его как сказано в данном FAQ в inetd.conf
     и services, сделал kill -HUP `cat /var/run/inetd.pid`, но
     $telnet localhost 119 не работает.
  
  A6:Необходимо наконец прочитать INSTALL в пакете leafnode и прописать
     правильно доступ в hosts.allow и, если у вас Linux то hosts.deny.

-----------------------------------------------------------------------------

  Q7:Стоит inn. Почему при запуске configure не может найти rnews и не хочет 
     из-за этого ничего конфигурить и создавать мэйкфайлы?
  
  А7:Дело в том, что rnews обычно имеет права news:news а юзер, запустивший
     скрипт configure, не имеет на rnews прав. Для того, чтоб configure
     проработал корректно, необходимо либо добавить юзера, собирающего
     фидогейт в группу news либо собирать от root.

-----------------------------------------------------------------------------

  Q8:Почему эхомейл тоссится, но в ньюсгруппах сообщения не появляются? В
     логах следующее:
     ===
     Oct 18 22:21:16 ftntoss packet /var/spool/bt/pin/9192da0c.pkt (1622b) from
     2:450/256.0 to 2:450/256.1
     Oct 18 22:21:16 ftntoss WARNING: node 2:450/256.0 have null password
     ===

  A8:Если у вас ходят непарольные пакеты, то не следует указывать в passwd на
     них пароли.
     Логично, не правда ли? В общем удали в passwd строки вида:
     === passwd ===
     packet  2:5030/1469             XXXXXXXX
     packet  2:5030/1229.0           XXXXXXXX
     packet  2:5030/1229.5           XXXXXXXX
     packet  2:5030/1229.6           XXXXXXXX
     packet  2:5030/1229.7           XXXXXXXX
     packet  2:5030/1229.8           XXXXXXXX
     ===
-----------------------------------------------------------------------------

  Q9:Почему fidogate режет 8-й бит в исходящих мессагах? Читалка настроена
     правильно - в спуле видны артикли plaint text 8bit.
     
  A9:Для того, чтобы указать fidogate-у формировать 8-битные мессаги в
     определенной группе, нужно к этой группе добавить ключ -8 в areas.

-----------------------------------------------------------------------------

  Q10:Почему при апгрейде fidogate в моих исходящих мессагах вдруг появилось
      много дополнительных RFC-кладжей. Это глюк?

  A10:Необходимо прочитать документацию на счет токена RFCLevel в основном
      конфиге и ключа -R конфига areas. В большинстве случаев достаточно
      выставить RFCLevel 0.

----------------------------------------------------------------------------

  Q11:А как можно организовать постинг отчетов о том, что прошло по файлэхам?
  
  A11:Например по крону запускать скрипт вида:
  ===
  #!/bin/sh
  #
  # (c) Evgeniy Kozhuhovskiy 2:450/256
  #
  if [ -f /var/log/fidogate/newfiles ] ; then 
   (
    echo "From: FileFix Daemon <filefix@f256.n450.z2.fidonet.org>"
    echo "Newsgroups: fido.pvt.xxx.station.robots"
    echo "Subject: New files arrived"
    echo 
    echo "New files on 2:450/256:"
    echo 
    cat /var/log/fidogate/newfiles
    echo "eof"
   )|inews -h -O -S
   # Это - опционально
   cat /var/log/fidogate/newfiles >>/var/log/fidogate/newfiles.full
   rm -f /var/log/fidogate/newfiles
  fi
  ===

----------------------------------------------------------------------------

  Q12:Может будут какие-то рекомендации на счет сборки fidogate-ds для
      крупного и мелкого гейта?

  A12:Для персонального гейта, которым будет пользоваться 1 человек, fidogate
      лучше собирать с опцией:
      ===
      ./configure --enable-dbc-history
      ===
      Оно же для freebsd порта WITH_DBC=yes. Тогда fidogate будет вести
      базу соответствия MSGID/Message-ID и при FIDO_MSGID, с которым по
      умолчанию собирается fidogate, не будут рваться треды и можно
      настраивать скоринг на свой Message-ID.

      Для крупного гейта:
      ===
      ./configure --disable-fs-msgid
      ===
      Оно же для freebsd порта WITHOUT_FMSGID=yes. Тогда fidogate будет
      писать в MSGID полный фидошный Message-ID. Еще рекомендую для
      совместимости с ifmail гейтами в fidogate.conf прописать опцию
      GateRfcKludge и RFCLevel 1. Это - оптимальные параметры.
      Категорически не рекомендую собирать fidogate для крупного гейта
      без опции --disable-fs-msgid, иначе будут возникать ломанные
      фидошные REPLY и с интернет-стороны невозможно будет пользоваться
      скорингом. Если скоринг еще можно починить пользуясь dbc-history,
      то ломанные REPLY будут постоянно.

----------------------------------------------------------------------------

  Q13:Где можно взять готовые пакеты fidogate-ds для моего дистрибутива?
  A13:Для Debian пакеты собирает Zhenja Kaluta и выкладывает на свой сайт:
       http://kaliuta.basnet.by/debian/
      Для FreeBSD можно взять в портах:
       ports/news/fidogate-ds
      или на сайте:
       http://freshports.org/news/fidogate-ds/
      Для ALTLinux собирает Zhenja Kaluta. Ищите на официальных зеркалах
      ALTLinux.
      Для RedHat-подобных(ASP, RH, FC) пакетов нет, но в сорсах fidogate-ds
      можно найти spec для сборки (<fgds-src>/packages/rpm/).

================================================================================
