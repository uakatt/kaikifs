#approximations_factory_spec.rb

require './lib/approximations_factory.rb'

describe ApproximationsFactory, ".build" do
  it 'returns singleton approximations correctly' do
    appr = ApproximationsFactory.build(
      'My name is %s.',
      'Sam')
    appr.should be_an_instance_of Array
    appr.size.should == 1
    appr[0].should == 'My name is Sam.'
  end

  it 'returns singleton approximations correctly' do
    appr = ApproximationsFactory.build(
      'My name is %s.',
      ['Sam'])
    appr.should be_an_instance_of Array
    appr.size.should == 1
    appr[0].should == 'My name is Sam.'
  end

  it 'returns multiple single approximations correctly' do
    appr = ApproximationsFactory.build(
      '%s there. My name is %s.',
      'Hello', 'Sam')
    appr.should be_an_instance_of Array
    appr.size.should == 1
    appr[0].should == 'Hello there. My name is Sam.'
  end

  it 'returns a single multiple approximations correctly' do
    appr = ApproximationsFactory.build(
      'My name is %s.',
      ['Sam', 'Greatest'])
    appr.should be_an_instance_of Array
    appr.size.should == 2
    appr[0].should == 'My name is Sam.'
    appr[1].should == 'My name is Greatest.'
  end

  it 'returns a single multiple approximations correctly' do
    appr = ApproximationsFactory.build(
      'My name is %s.',
      [['Sam', 'Greatest']])
    appr.should be_an_instance_of Array
    appr.size.should == 2
    appr[0].should == 'My name is Sam.'
    appr[1].should == 'My name is Greatest.'
  end

  it 'returns multiple multiple approximations correctly' do
    appr = ApproximationsFactory.build(
      '%s there. My name is %s.',
      ['Hi', 'Hello'],
      ['Sam', 'Greatest'])
    appr.should be_an_instance_of Array
    appr.size.should == 4
    appr[0].should == 'Hi there. My name is Sam.'
    appr[1].should == 'Hi there. My name is Greatest.'
    appr[2].should == 'Hello there. My name is Sam.'
    appr[3].should == 'Hello there. My name is Greatest.'
  end

  it 'returns multiple multiple approximations correctly' do
    appr = ApproximationsFactory.build(
      '%s there. My name is %s.',
      [['Hi',  'Hello'],
       ['Sam', 'Greatest']
      ])
    appr.should be_an_instance_of Array
    appr.size.should == 4
    appr[0].should == 'Hi there. My name is Sam.'
    appr[1].should == 'Hi there. My name is Greatest.'
    appr[2].should == 'Hello there. My name is Sam.'
    appr[3].should == 'Hello there. My name is Greatest.'
  end

  it 'returns the right stuff for my crazy xpaths' do
    appr = ApproximationsFactory.build(
      "//%s[contains(text()%s, '%s')]/../following-sibling::td/%s",
      ['th/label', 'th/div'],
      ['', '[1]', '[2]', '[3]'],
      ['Group Id'],
      ['select[1]', 'input[1]'])
    appr.should be_an_instance_of Array
    appr.size.should == 16
    appr[ 0].should == "//th/label[contains(text(), 'Group Id')]/../following-sibling::td/select[1]"
    appr[ 1].should == "//th/label[contains(text(), 'Group Id')]/../following-sibling::td/input[1]"
    appr[ 2].should == "//th/label[contains(text()[1], 'Group Id')]/../following-sibling::td/select[1]"
    appr[ 3].should == "//th/label[contains(text()[1], 'Group Id')]/../following-sibling::td/input[1]"
    appr[ 4].should == "//th/label[contains(text()[2], 'Group Id')]/../following-sibling::td/select[1]"
    appr[ 5].should == "//th/label[contains(text()[2], 'Group Id')]/../following-sibling::td/input[1]"
    appr[ 6].should == "//th/label[contains(text()[3], 'Group Id')]/../following-sibling::td/select[1]"
    appr[ 7].should == "//th/label[contains(text()[3], 'Group Id')]/../following-sibling::td/input[1]"
    appr[ 8].should == "//th/div[contains(text(), 'Group Id')]/../following-sibling::td/select[1]"
    appr[ 9].should == "//th/div[contains(text(), 'Group Id')]/../following-sibling::td/input[1]"
    appr[10].should == "//th/div[contains(text()[1], 'Group Id')]/../following-sibling::td/select[1]"
    appr[11].should == "//th/div[contains(text()[1], 'Group Id')]/../following-sibling::td/input[1]"
    appr[12].should == "//th/div[contains(text()[2], 'Group Id')]/../following-sibling::td/select[1]"
    appr[13].should == "//th/div[contains(text()[2], 'Group Id')]/../following-sibling::td/input[1]"
    appr[14].should == "//th/div[contains(text()[3], 'Group Id')]/../following-sibling::td/select[1]"
    appr[15].should == "//th/div[contains(text()[3], 'Group Id')]/../following-sibling::td/input[1]"
  end
end

describe ApproximationsFactory, ".transpose_build" do
  it 'returns the right stuff for my crazy xpaths' do
    appr = ApproximationsFactory.transpose_build(
      "//%s[contains(text()%s, 'Group Id')]/../following-sibling::td/%s",
      ['th/label',    '',       'select[1]'],
      ['th/div',      '[1]',    'input[1]'],
      [nil,           '[2]',    nil],
      [nil,           '[3]',    nil])
    appr.should be_an_instance_of Array
    appr.size.should == 16
    appr[ 0].should == "//th/label[contains(text(), 'Group Id')]/../following-sibling::td/select[1]"
    appr[ 1].should == "//th/label[contains(text(), 'Group Id')]/../following-sibling::td/input[1]"
    appr[ 2].should == "//th/label[contains(text()[1], 'Group Id')]/../following-sibling::td/select[1]"
    appr[ 3].should == "//th/label[contains(text()[1], 'Group Id')]/../following-sibling::td/input[1]"
    appr[ 4].should == "//th/label[contains(text()[2], 'Group Id')]/../following-sibling::td/select[1]"
    appr[ 5].should == "//th/label[contains(text()[2], 'Group Id')]/../following-sibling::td/input[1]"
    appr[ 6].should == "//th/label[contains(text()[3], 'Group Id')]/../following-sibling::td/select[1]"
    appr[ 7].should == "//th/label[contains(text()[3], 'Group Id')]/../following-sibling::td/input[1]"
    appr[ 8].should == "//th/div[contains(text(), 'Group Id')]/../following-sibling::td/select[1]"
    appr[ 9].should == "//th/div[contains(text(), 'Group Id')]/../following-sibling::td/input[1]"
    appr[10].should == "//th/div[contains(text()[1], 'Group Id')]/../following-sibling::td/select[1]"
    appr[11].should == "//th/div[contains(text()[1], 'Group Id')]/../following-sibling::td/input[1]"
    appr[12].should == "//th/div[contains(text()[2], 'Group Id')]/../following-sibling::td/select[1]"
    appr[13].should == "//th/div[contains(text()[2], 'Group Id')]/../following-sibling::td/input[1]"
    appr[14].should == "//th/div[contains(text()[3], 'Group Id')]/../following-sibling::td/select[1]"
    appr[15].should == "//th/div[contains(text()[3], 'Group Id')]/../following-sibling::td/input[1]"
  end
end
