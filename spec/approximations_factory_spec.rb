#approximations_factory_spec.rb

require './lib/approximations_factory.rb'

describe ApproximationsFactory, ".build" do
  it 'returns singleton approximations correctly' do
    appr = ApproximationsFactory.build(
      'My name is %s.',
      'Sam')
    appr.size.should == 1
    appr[0].should == 'My name is Sam.'

    appr = ApproximationsFactory.build(
      'My name is %s.',
      ['Sam'])
    puts appr.inspect
    appr.size.should == 1
    appr[0].should == 'My name is Sam.'
  end

  it 'returns multiple single approximations correctly' do
    appr = ApproximationsFactory.build(
      '%s there. My name is %s.',
      'Hello', 'Sam')
    appr.size.should == 1
    appr[0].should == '%s there. My name is %s.'
  end

  it 'returns a single multiple approximations correctly' do
    appr = ApproximationsFactory.build(
      'My name is %s.',
      ['Sam', 'Greatest'])
    appr.size.should == 2
    appr[0].should == 'My name is Sam.'
    appr[1].should == 'My name is Greatest.'

    appr = ApproximationsFactory.build(
      'My name is %s.',
      [['Sam', 'Greatest']])
    appr.size.should == 2
    appr[0].should == 'My name is Sam.'
    appr[1].should == 'My name is Greatest.'
  end

  it 'returns multiple multiple approximations correctly' do
    appr = ApproximationsFactory.build(
      '%s there. My name is %s.',
      ['Hi', 'Hello'],
      ['Sam', 'Greatest'])
    appr.size.should == 2
    appr[0].should == 'My name is Sam.'
    appr[1].should == 'My name is Greatest.'

    appr = ApproximationsFactory.build(
      '%s there. My name is %s.',
      [['Hi',  'Hello'],
       ['Sam', 'Greatest']
      ])
    appr.size.should == 4
    appr[0].should == 'Hi there. My name is Sam.'
    appr[1].should == 'Hi there. My name is Greatest.'
    appr[2].should == 'Hello there. My name is Sam.'
    appr[3].should == 'Hello there. My name is Greatest.'
  end
end
